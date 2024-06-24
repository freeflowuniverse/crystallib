module couchdb

import freeflowuniverse.crystallib.clients.httpconnection
import json

// one specific DB in the CouchDB server
pub struct CouchDBInstance {
pub mut:
	// db name
	name       string
	connection &httpconnection.HTTPConnection
}

@[params]
pub struct DBSecurity {
pub mut:
	admins  DBUsers
	members DBUsers
}

@[params]
pub struct DBUsers {
pub mut:
	names []string
	roles []string
}

pub struct DB {
pub mut:
	instance_start_time u64
	db_name             string
	purge_seq           string
	update_seq          string
	sizes               Sizes
	props               Props
	doc_del_count       u64
	doc_count           u64
	disk_format_version u64
	compact_running     bool
	cluster             Cluster
}

pub struct Sizes {
pub mut:
	file     u64
	external u64
	active   u64
}

pub struct Props {
pub mut:
	partitioned bool
}

pub struct Cluster {
pub mut:
	n u64
	q u64
	r u64
	w u64
}

pub fn (mut cl CouchDBInstance) get_db() !DB {
	res := cl.connection.send(method: .get, prefix: cl.name)!
	if !res.is_ok() {
		return error('failed to get db: (${res.code}) ${res.data}')
	}

	db := json.decode(DB, res.data)!
	return db
}

pub fn (mut cl CouchDBInstance) get_document[T](doc_id string) !T {
	res := cl.connection.send(method: .get, prefix: '${cl.name}/${doc_id}')!
	if !res.is_ok() {
		return error('failed to get document: (${res.code}) ${res.data}')
	}

	doc := json.decode(T, res.data)!
	return doc
}

pub fn (mut cl CouchDBInstance) create_docuemnt[T](doc T) ! {
	res := cl.connection.send(method: .post, prefix: cl.name, data: json.encode(doc))!
	if !res.is_ok() {
		return error('failed to create document: (${res.code}) ${res.data}')
	}
}

pub fn (mut cl CouchDBInstance) create_or_update_document[T](doc_id string, doc T) ! {
	res := cl.connection.send(method: .put, prefix: '${cl.name}/${doc_id}', data: json.encode(doc))!
	if !res.is_ok() {
		return error('failed to create/update document: (${res.code}) ${res.data}')
	}
}

pub fn (mut cl CouchDBInstance) delete(doc_id string) ! {
	res := cl.connection.send(method: .delete, prefix: '${cl.name}/${doc_id}')!
	if !res.is_ok() {
		return error('failed to delete document: (${res.code}) ${res.data}')
	}
}

// pub fn (mut cl CouchDBInstance) query(...)!{

// }
