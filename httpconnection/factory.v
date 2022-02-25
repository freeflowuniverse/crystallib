module httpconnection

import net.http
import despiegk.crystallib.redisclient
import json
// import despiegk.crystallib.crystaljson

pub struct HTTPConnectionSettings {
pub mut:
	//as used to identity in redis
	cache_key 			string
	cache_enable 		bool 
	//if this is set it means we will cache the fact an error happened too
	cache_error		bool = true	
	//default timeout is 1h
	cache_timeout 		int = 3600
	//retry, default only 1 time
	retry 				int = 1
	//if async threads will be used
	async				bool	
}

struct EmptyHeader {}

[heap]
pub struct HTTPConnection {
pub mut:
	redis         &redisclient.Redis
	//the base url, can be more than 1, useful in case of retry
	url           		[]string
	header_default      http.Header
	settings      		HTTPConnectionSettings
}


[heap]
pub struct HTTPConnections {
pub mut:
	connections map[string]&HTTPConnection
}

fn init_factory() HTTPConnections {
	mut htpc := HTTPConnections{}
	return htpc
}

// Singleton creation
const factory = init_factory()



pub fn new(name string, url string, cache bool) &HTTPConnection {

	mut f := httpconnection.factory

	mut header := http.new_header_from_map({
		http.CommonHeader.content_type:  'application/json'
	})
	mut conn := HTTPConnection{
		redis: redisclient.get_unixsocket_new_default() or { panic(err) }
		header_default: header
	}

	conn.settings.cache_enable = cache
	conn.url = [url]
	conn.settings.cache_key = name	

	f.connections[name] = &conn

	return f.connections[name]

}

//see readme how to use
pub fn get(name string) ?&HTTPConnection {
	mut f := httpconnection.factory
	if ! (name in f.connections) {
		return error("cannot find httpconnection with name $name .")	
	}
	mut r := f.connections[name]
	return r
}

pub fn (mut h HTTPConnection) url_get() string {
	return h.url[0].trim(" /")
}



pub struct Request{
pub mut:
	id				string
	prefix 			string
	dict_key		string
	postdata 		string
	//result from the query (can be an error)
	result 			string
	//resultcode >0 if error
	//resultcode = 999998 was not in cache, but we don't know on source
	//resultcode = 999999 if empty (from source or was in cache)
	result_code		int
	//if false the disable & enable, then will not overrule the default for the connection
	cache_disable 	bool
	cache_enable	bool
	header 			EmptyHeader | http.Header = EmptyHeader{}
}

//get request with header filled in
fn (mut h HTTPConnection) request() Request {
	return Request{
		header : EmptyHeader{}
	}
}


pub fn (mut h HTTPConnection) clone() ?&HTTPConnection {

	mut r := redisclient.get_unixsocket_new_default()?

	mut header := http.new_header_from_map({
		http.CommonHeader.content_type:  'application/json'
	})
	mut conn := HTTPConnection{
		redis: r
		header_default: header
	}

	conn.settings.cache_enable = h.settings.cache_enable
	conn.url = h.url
	conn.settings.cache_key = h.settings.cache_key	

	return &conn

}


fn (mut r Request) json() string {
	return json.encode_pretty(r)
}


