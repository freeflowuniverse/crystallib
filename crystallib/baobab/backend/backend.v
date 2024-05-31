module backend

import os
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.data.encoderhero

pub struct Backend {
mut:
	indexer Indexer
	dbs     dbfs.DBCollection
}

@[params]
pub struct BackendConfig {
	name   string
	secret string
}

pub fn new(config BackendConfig) !Backend {
	mut backend := Backend{
		indexer: new_indexer('${os.home_dir()}/hero/db/${config.name}.sqlite')!
		dbs: dbfs.get(
			contextid: 1
			secret: config.secret
		)!
	}
	return backend
}

pub fn (mut backend Backend) new[T](obj_ T) !u32 {
	mut obj := obj_
	mut db := backend.dbs.db_get_create(name: get_table_name[T]()) or {
		return error('Failed to get database for object <${T.name}>\n${err}')
	}
	backend.indexer.new[T](obj)!

	// $for field in T.fields {
	// 	if field.name == 'id' {
	// 		obj.id = id
	// 	}
	// 	else if field.name == 'Base' {
	// 		obj.id = id
	// 	}
	// }
	data := encoderhero.encode[T](obj)!
	obj.id = db.set(value: data) or {return error('Failed to set data ${err}')}
	return db.set(id: obj.id, value: encoderhero.encode[T](obj)!)
}

pub fn (mut backend Backend) set[T](obj T) ! {
	mut db := backend.dbs.db_get_create(name: get_table_name[T]()) or {
		return error('Failed to get database for object <${T.name}>\n${err}')
	}
	backend.indexer.set[T](obj) or {
		return error('Failed to set new indices:\n${err}')
	}
	data := encoderhero.encode[T](obj)!
	// TODO: see if data changed
	db.set(value: data)!
}

pub fn (mut backend Backend) delete[T](id u32) ! {
	backend.indexer.delete[T](id)!
	mut db := backend.dbs.db_get_create(name:get_table_name[T]())!
	db.delete(id: id)!
}

pub fn (mut backend Backend) get[T](id u32) !T {
	mut db := backend.dbs.db_get_create(name: get_table_name[T]())!
	data := db.get(id: id) or {	
		return error('Failed to get ${T.name} object with id: ${id}')
	}
	if data == '' {
		return error('Failed to get ${T.name} object with id: ${id}')
	}
	return encoderhero.decode[T](data)!
}

pub fn (mut backend Backend) list[T]() ![]T {
	mut db := backend.dbs.db_get_create(name: get_table_name[T]())!
	ids := db.ids()!
	datas := ids.map(db.get(id: it)!)
	mut results := []T{}
	// TODO: report v compiler bug with stmt below
	// results = datas.map(encoderhero.decode[T](it)!)
	for data in datas {
		results << encoderhero.decode[T](data)!
	}
	return results
}

pub fn (mut backend Backend) filter[T, D](filter D, params FilterParams) ![]T {
	mut db := backend.dbs.db_get_create(get_table_name[T]())!
	ids := backend.indexer.filter[T, D](filter, params)!
	datas := ids.map(db.get('${it}')!)
	return datas.map(encoderhero.decode[T](it)!)
}

pub fn (mut backend Backend) reset() ! {
	backend.dbs.destroy()!
}