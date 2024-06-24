module couchdb
import freeflowuniverse.crystallib.clients.httpconnection

//one specific DB in the CouchDB server
pub struct CouchDBInstance {
pub mut:
	connection &httpconnection.HTTPConnection
}

//see http://127.0.0.1:5984/_utils/docs/intro/api.html what to support

pub fn (mut cl CouchDBInstance) get(...)!{

}

pub fn (mut cl CouchDBInstance) set(...)!{

}

pub fn (mut cl CouchDBInstance) delete(...)!{

}

pub fn (mut cl CouchDBInstance) query(...)!{

}
