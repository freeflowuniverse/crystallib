module httpconnection

import net.http
import despiegk.crystallib.redisclient

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
	empty_redis := redisclient.Redis{}
	mut conn := HTTPConnection{
		redis: &empty_redis
		header_default: header
		settings: HTTPConnectionSettings{
			cache_disable: !cache
		}
		url: [url.trim('/')]
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
