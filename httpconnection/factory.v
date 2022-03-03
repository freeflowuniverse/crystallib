module httpconnection

import net.http
import despiegk.crystallib.redisclient
import json

pub struct HTTPConnectionSettings {
pub mut:
	cache_key     string // as used to identity in redis
	cache_disable bool // Default false --> cache working
	cache_error   bool // if this is set it means we will cache the fact an error happened too
	cache_timeout int = 3600 // default timeout is 1h
	retry         int = 1 // retry, default only 1 time
	async         bool // if async threads will be used
}

struct EmptyHeader {}

[heap]
pub struct HTTPConnection {
pub mut:
	redis          &redisclient.Redis
	url            []string // the base url, can be more than 1, useful in case of retry
	header_default http.Header
	settings       HTTPConnectionSettings
}

[heap]
pub struct HTTPConnections {
pub mut:
	connections map[string]&HTTPConnection
}

// [param]
pub struct Request {
pub mut:
	id       string
	prefix   string
	dict_key string
	postdata string
	result   string // result from the query (can be an error)
	// resultcode >0 if error
	// resultcode = 999998 was not in cache, but we don't know on source
	// resultcode = 999999 if empty (from source or was in cache)
	result_code int
	cache_disable  bool
	header        EmptyHeader | http.Header = EmptyHeader{}
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
		http.CommonHeader.content_type: 'application/json'
	})

	// Init conenection
	empty_redis := redisclient.Redis{}
	mut conn := HTTPConnection{
		redis: &empty_redis
		header_default: header
		settings : HTTPConnectionSettings{cache_disable: !cache}
		url : [url]
	}

	// Check cache and init redis using unix_socket
	if cache {
		conn.redis = redisclient.get_unixsocket_new_default() or { panic(err) }
		conn.settings.cache_key = name
	}

	// Store new connection
	f.connections[name] = &conn

	return f.connections[name]
}

pub fn get(name string) ?&HTTPConnection {
	mut f := httpconnection.factory
	mut r := f.connections[name] or { return error('cannot find httpconnection with name $name .') }
	return r
}

//FIXME: Remove if not needed
pub fn (mut h HTTPConnection) url_get() string {
	return h.url[0].trim(' /')
}

// get request with header filled in
fn (mut h HTTPConnection) request() Request {
	return Request{
		header: EmptyHeader{}
	}
}

// FIXME: REMOVE if not needed
pub fn (mut h HTTPConnection) clone() ?&HTTPConnection {
	mut r := redisclient.get_unixsocket_new_default() ?

	mut header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json'
	})
	mut conn := HTTPConnection{
		redis: r
		header_default: header
	}

	conn.settings.cache_disable = h.settings.cache_disable
	conn.url = h.url
	conn.settings.cache_key = h.settings.cache_key

	return &conn
}

fn (mut r Request) json() string {
	return json.encode_pretty(r)
}
