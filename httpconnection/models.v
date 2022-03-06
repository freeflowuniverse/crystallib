module httpconnection

import net.http { Header, Method }
import despiegk.crystallib.redisclient { Redis }

// Success response from 200 to 399
const success_responses = []int{len: 200, init: it + 200}

pub struct HTTPConnectionSettings {
pub mut:
	cache_key               string // as used to identity in redis
	cache_allowable_methods []Method = [.get, .head]
	cache_allowable_codes   []int    = httpconnection.success_responses
	cache_disable           bool // Default false --> cache working
	cache_timeout           int = 3600 // default timeout is 1h
	// retry         int = 1 // retry, default only 1 time
	// async         bool   // if async threads will be used
}

[heap]
pub struct HTTPConnection {
pub mut:
	redis          &Redis
	url            []string // the base url, can be more than 1, useful in case of retry
	header_default Header
	settings       HTTPConnectionSettings
}

[heap]
pub struct HTTPConnections {
pub mut:
	connections map[string]&HTTPConnection
}

[params]
pub struct RequestArgs {
pub mut:
	method        Method
	prefix        string
	id            string
	data          string
	cache_disable bool // if you need to disable cache, set req.cache_disable true
	header        Header
	// retry         int
	dict_key string // TODO: Remove in my opinion
}

[param]
pub struct Result {
pub mut:
	code int
	data string
}
