module httpconnection

import net.http
import freeflowuniverse.crystallib.redisclient

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

	if url.replace(' ', '') == '' {
		panic("URL is empty, can't create http connection with empty url")
	}

	// Init conenection
	// empty_redis := redisclient.Redis{}
	mut conn := HTTPConnection{
		redis: redisclient.core_get()
		default_header: header
		cache: CacheConfig{
			disable: !cache
			key: name
		}
		base_url: url.trim('/')
	}

	// Store new connection
	f.connections[name] = &conn

	res:=f.connections[name] or {panic("couldn't find key '$name' in f.connections")}
	return res
}

pub fn get(name string) !&HTTPConnection {
	mut f := httpconnection.factory
	mut r := f.connections[name] or {
		return error('cannot find httpconnection with name ${name} .')
	}
	return r
}

pub fn (mut h HTTPConnection) clone() &HTTPConnection {
	if h.cache.disable {
		return h
	}
	mut new_conn := h
	new_conn.redis = redisclient.core_get()
	return &new_conn
}
