module actor_backend

import json
import db.sqlite
import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.data.encoderhero

pub struct Backend {
	indexer Indexer
	dbs dbfs.DBCollection
}

pub fn new(db_path string) !Backend {
	mut backend := Backend{
		indexer: new_indexer(db_path)!
	}

	return backend
}

pub fn (mut backend Backend) new[T](obj T) !int {
	db := backend.dbs.get(get_table_name[T])
	id := backend.indexer.new[T](obj)!
	data := encoderhero.encode[T](obj)!
	db.set(id, data)!
	return id
}

pub fn (mut backend Backend) set[T](mut obj T) ! {
	db := backend.dbs.get(get_table_name[T])
	backend.indexer.set[T](obj)!
	data := encoderhero.encode[T](obj)!
	// TODO: see if data changed
	db.set(obj.id, data)!
}

pub fn (mut backend Backend) delete[T](id int) ! {
	backend.indexer.delete[T](id)!
	db := backend.dbs.get(get_table_name[T])
	return db.delete(id)!
}

pub fn (mut backend Backend) get[T](id int) !T {
	db := backend.dbs.get(get_table_name[T])
	data := db.get(id)!
	return heroencoder.decode[T](data)!
}

pub fn (mut backend Backend) list[T]() ![]T {
	db := backend.dbs.get(get_table_name[T])
	keys := db.keys()!
	datas := keys.map(db.get(it)!)
	return datas.map(heroencoder.decode[T](it)!)
}

pub fn (mut backend Backend) filter[T](params FilterParams) ![]T {
	db := backend.dbs.get(get_table_name[T])
	ids := backend.indexer.filter(params)!
	datas := ids.map(db.get(it)!)
	return datas.map(heroencoder.decode[T](it)!)
}