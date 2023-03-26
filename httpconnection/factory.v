module httpconnection

import net.http
import freeflowuniverse.crystallib.redisclient

fn init_factory() HTTPConnections {
	mut htpc := HTTPConnections{}
	return htpc
}

// Singleton creation
const factory = init_factory()

[params]
pub struct HTTPConnectionArgs {
pub:
	name  string [required]
	url   string [required]
	cache bool = true
}

pub fn new(args HTTPConnectionArgs) &HTTPConnection {
	mut f := httpconnection.factory

	mut header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json'
	})

	if args.url.replace(' ', '') == '' {
		panic("URL is empty, can't create http connection with empty url")
	}

	// Init connection
	mut conn := HTTPConnection{
		redis: redisclient.core_get()
		default_header: header
		cache: CacheConfig{
			disable: !args.cache
			key: args.name
		}
		base_url: args.url.trim('/')
	}

	// Store new connection
	f.connections[args.name] = &conn

	res := f.connections[args.name] or {
		panic("couldn't find key '${args.name}' in f.connections")
	}
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
