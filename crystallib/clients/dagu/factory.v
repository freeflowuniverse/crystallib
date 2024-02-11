module dagu

// import os
import freeflowuniverse.crystallib.clients.httpconnection
import os

pub struct DaguClient {
mut:
	connection &httpconnection.HTTPConnection
}

@[params]
pub struct ClientConfig {
	url      string = 'http://localhost:8080'
	username string
	password string
}

pub fn new(config ClientConfig) !DaguClient {
	mut conn := httpconnection.new(
		name: 'dagu'
		url: '${config.url}/api/v1'
	)!
	conn.basic_auth(config.username, config.password)
	return DaguClient{
		connection: conn
	}
}
