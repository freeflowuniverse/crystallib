module httpconnection

import net.http { Header, Method }
import despiegk.crystallib.redisclient { Redis }

// https://cassiomolin.com/2016/09/09/which-http-status-codes-are-cacheable/
const default_cache_allowable_codes = [200, 203, 204, 206, 300, 404, 405, 410, 414, 501]

const unsafe_http_methods = [Method.put, .patch, .post, .delete]

pub struct HTTPConnectionSettings {
pub mut:
	cache_key               string // as used to identity in redis
	cache_allowable_methods []Method = [.get, .head]
	cache_allowable_codes   []int    = httpconnection.default_cache_allowable_codes
	cache_disable           bool // Default false --> cache working
	cache_timeout           int = 3600 // default timeout is 1h
	match_headers           bool // cache the request header to be matched later
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
pub struct Request {
pub mut:
	method        Method
	prefix        string
	id            string
	params        map[string]string
	data          string
	cache_disable bool // if you need to disable cache, set req.cache_disable true
	header        Header
	dict_key      string
	// retry         int
}

[param]
pub struct Result {
pub mut:
	code int
	data string
}
