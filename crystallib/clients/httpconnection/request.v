module httpconnection

import net.http { Header, Method }

@[params]
pub struct Request {
pub mut:
	method        Method
	prefix        string
	id            string
	params        map[string]string
	data          string
	cache_disable bool = true
	header        Header
	dict_key      string
	debug         bool
}

// get new request
//
// ```
// method        Method (.get, .post, .put, ...)
// prefix        string
// id            string
// params        map[string]string
// data          string
// cache_disable bool = true
// header        Header
// dict_key      string
// ```	
// for header see https://modules.vlang.io/net.http.html#Method .
// for method see https://modules.vlang.io/net.http.html#Header
pub fn new_request(args_ Request) !&Request {
	mut args := args_
	mut header := http.new_header_from_map({
		http.CommonHeader.content_type: 'application/json'
	})
	args.header = header
	return &args
}
