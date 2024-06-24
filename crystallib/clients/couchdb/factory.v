module couchdb

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.clients.httpconnection

// import freeflowuniverse.crystallib.ui.console

pub struct CouchDBClient[T] {
	base.BaseConfig[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

@[params]
pub struct Config {
pub mut:
	url       string
	username  string
	password  string
}

pub fn get(instance string, cfg Config) !CouchDBClient[Config] {
	mut self := CouchDBClient[Config]{
		connection: &httpconnection.HTTPConnection{}
	}

	if cfg.username.len > 0 {
		// first the type of the instance, then name of instance, then action
		self.init('CouchDBclient', instance, .set, cfg)!
	} else {
		self.init('CouchDBclient', instance, .get)!
	}

	mut conn := httpconnection.new(
		name: 'CouchDB'
		url: '${cfg.url}'
	)!

	//TODO: ...
	// conn.default_header.add(.authorization, 'Bearer ${self.config()!.apisecret}')
	// req.add_custom_header('x-disable-pagination', 'True') !

	self.connection = conn
	return self
}

//TODO: implement play... for configuraton