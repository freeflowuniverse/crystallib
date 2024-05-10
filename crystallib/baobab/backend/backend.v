module backend

import os
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.data.encoderhero

pub struct Backend {
mut:
	indexer Indexer
	dbs dbfs.DBCollection
}

[params]
pub struct BackendConfig {
	name string
	secret string
}

pub fn new(config BackendConfig) !Backend {
	mut backend := Backend{
		indexer: new_indexer('${os.home_dir()}/hero/db/${config.name}.sqlite')!
		dbs: dbfs.get(
			context: config.name
			secret: config.secret
		)!
	}
	return backend
}

pub fn (mut backend Backend) new[T](obj_ T) !string {
	mut obj := obj_
	mut db := backend.dbs.get(get_table_name[T]())!
	id := backend.indexer.new[T](obj)!

	$for field in T.fields {
		if field.name == 'id' {
			obj.id = '${id}'
		}
		else if field.name == 'Base' {
			obj.id = '${id}'
		}
	}

	data := encoderhero.encode[T](obj)!
	db.set('${id}', data)!
	return '${id}'
}

pub fn (mut backend Backend) set[T](obj T) ! {
	mut db := backend.dbs.get(get_table_name[T]())!
	backend.indexer.set[T](obj)!
	data := encoderhero.encode[T](obj)!
	// TODO: see if data changed
	db.set('${obj.id}', data)!
}

pub fn (mut backend Backend) delete[T](id string) ! {
	backend.indexer.delete[T](id)!
	mut db := backend.dbs.get(get_table_name[T]())!
	db.delete('${id}')!
}

pub fn (mut backend Backend) get[T](id string) !T {
	mut db := backend.dbs.get(get_table_name[T]())!
	data := db.get(id)!
	if data == '' {
		return error('Failed to get ${T.name} object with id: ${id}')
	}
	return encoderhero.decode[T](data)!
}

pub fn (mut backend Backend) list[T]() ![]T {
	mut db := backend.dbs.get(get_table_name[T]())!
	keys := db.keys('')!
	datas := keys.map(db.get(it)!)
	return datas.map(encoderhero.decode[T](it)!)
}

pub fn (mut backend Backend) filter[T,D](filter D, params FilterParams) ![]T {
	mut db := backend.dbs.get(get_table_name[T]())!
	ids := backend.indexer.filter[T, D](filter, params)!
	datas := ids.map(db.get('${it}')!)
	return datas.map(encoderhero.decode[T](it)!)
}