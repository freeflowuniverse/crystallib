module httpconnection

import net.http { Header, Method }
import despiegk.crystallib.redisclient { Redis }

pub struct HTTPConnectionSettings {
pub mut:
	cache_key     string // as used to identity in redis
	cache_disable bool   // Default false --> cache working
	cache_error   bool   // if this is set it means we will cache the fact an error happened too
	cache_timeout int = 3600 // default timeout is 1h
	retry         int = 1 // retry, default only 1 time
	async         bool   // if async threads will be used
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

[param]
pub struct RequestArgs {
pub mut:
	method        Method
	prefix        string
	id            string
	data          string
	cache_disable bool // if you need to disable cache, set req.cache_disable true
	header        Header
	retry         int
	dict_key      string // TODO: Remove in my opinion
}

[param]
pub struct Result {
pub mut:
	code int
	data string
}

const success_responses = [200, 201, 202, 204]
