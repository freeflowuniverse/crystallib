module coinmarketcap
import os
import x.json2
import net.http
import redisclient
import crypto.md5

struct CoinMarketConnection {
mut:
	redis         redisclient.Redis
	url           string
	secret		  string
	// auth          AuthDetail
	cache_timeout int
}

fn init_connection() CoinMarketConnection {
	return CoinMarketConnection{
		redis: redisclient.connect('127.0.0.1:6379') or { redisclient.Redis{} }
	}
}

pub struct CMCNewArgs {
pub mut:	
	secret string
	cache_timeout int
	
}

pub fn new(args CMCNewArgs) CoinMarketConnection {
	/*
	Create a new taiga client
	Inputs:
		secre: see CoinMarket API key
		cache_timeout: Expire time in seconds for caching

	Output:
		CoinMarketConnection: Client contains taiga auth details, taiga url, redis cleint and cache timeout.
	*/
	mut updated_args := args
	if args.secret=="" && "CMCKEY" in os.environ(){
		updated_args.secret = os.environ()["CMCKEY"]
	}
	if args.cache_timeout==0{
		updated_args.cache_timeout = 3600*12
	}
	mut conn := init_connection()
	conn.url = "https://pro-api.coinmarketcap.com/v1"
	conn.secret = updated_args.secret
	conn.cache_timeout = updated_args.cache_timeout

	if conn.secret == "" {
		panic("secret not specified, use env arg for CMCKEY")
	}

	return conn
}

fn (mut h CoinMarketConnection) header() ?http.Header {
	/*
	Create a new header for Content type and Authorization

	Output:
		header: http.Header with the needed headers
	*/
	mut header := http.new_header_from_map(map{
		http.CommonHeader.content_type:  'application/json'
		http.CommonHeader.accept:  'application/json'
		http.CommonHeader.accept_encoding: 'deflate, gzip'
	})
	header.add_custom('X-CMC_PRO_API_KEY', h.secret)?
	return header
}

fn cache_key(prefix string, reqdata string) string {
	/*
	Create Cache Key
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.

	Output:
		cache_key: key that will be used in redis
	*/
	mut ckey := ''
	if reqdata == '' {
		ckey = 'taiga:' + prefix
	} else {
		ckey = 'taiga:' + prefix + ':' + md5.hexhash(reqdata)
	}
	return ckey
}

fn (mut h CoinMarketConnection) cache_get(prefix string, reqdata string, cache bool) string {
	/*
	Get from Cache
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		cache: Flag to enable caching.
	Output:
		result: If cache ture and no thing stored or cache false will return empty string
	*/
	mut text := ''
	if cache {
		text = h.redis.get(cache_key(prefix, reqdata)) or { '' }
	}
	return text
}

fn (mut h CoinMarketConnection) cache_set(prefix string, reqdata string, data string, cache bool) ? {
	/*
	Set Cache
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		reqdata: data used in the request.
		data: Json encoded data.
		cache: Flag to enable caching.
	*/
	if cache {
		key := cache_key(prefix, reqdata)
		h.redis.set(key, data) ?
		h.redis.expire(key, h.cache_timeout) or {
			panic('should never get here, if redis worked expire should also work.$err')
		}
	}
}

fn (mut h CoinMarketConnection) cache_drop() ? {
	/*
	Drop all cache related to taiga
	*/
	all_keys := h.redis.keys('taiga:*') ?
	for key in all_keys {
		h.redis.del(key) ?
	}
	// TODO:: maintain authentication & reconnect (Need More Info)
}

fn (mut h CoinMarketConnection) post_json(prefix string, postdata string, cache bool, authenticated bool) ?map[string]json2.Any {
	/*
	Post Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		postdata: Json encoded data.
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as Json2 struct.
	*/
	mut result := h.cache_get(prefix, postdata, cache)
	// Post with auth header
	if result == '' && authenticated {
		mut req := http.new_request(http.Method.post, '$h.url/api/v1/$prefix', postdata) ?
		req.header = h.header() ?
		println(req)
		response := req.do() ?
		result = response.text
	}
	// Post without auth header
	else {
		response := http.post_json('$h.url/api/v1/$prefix', postdata) ?
		result = response.text
	}
	h.cache_set(prefix, postdata, result, cache) ?
	data_raw := json2.raw_decode(result) ?
	data := data_raw.as_map()
	return data
}

fn (mut h CoinMarketConnection) post_json_str(prefix string, postdata string, cache bool, authenticated bool) ?string {
	/*
	Post Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		postdata: Json encoded data.
		cache: Flag to enable caching.
		authenticated: Flag to add authorization flag with the request.

	Output:
		response: response as string.
	*/
	mut result := h.cache_get(prefix, postdata, cache)
	// Post with auth header
	if result == '' && authenticated {
		mut req := http.new_request(http.Method.post, '$h.url/api/v1/$prefix', postdata) ?
		req.header = h.header() ?
		println(req)
		response := req.do() ?
		result = response.text
	}
	// Post without auth header
	else {
		response := http.post_json('$h.url/api/v1/$prefix', postdata) ?
		result = response.text
	}
	h.cache_set(prefix, postdata, result, cache) ?
	return result
}

fn (mut h CoinMarketConnection) get_json(prefix string, data string, cache bool) ?map[string]json2.Any {
	/*
	Get Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as Json2.Any map.
	*/
	mut result := h.cache_get(prefix, data, cache)
	if result == '' {
		// println("MISS1")
		mut req := http.new_request(http.Method.get, '$h.url/api/v1/$prefix', data) ?
		req.header = h.header() ?
		res := req.do() ?
		result = res.text
	}
	// means empty result from cache
	if result == 'NULL' {
		result = ''
	}
	h.cache_set(prefix, data, result, cache) ?
	data_raw := json2.raw_decode(result) ?
	data2 := data_raw.as_map()
	return data2
}

fn (mut h CoinMarketConnection) get_json_str(prefix string, data string, query string,cache bool) ?string {
	/*
	Get Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response as string.
	*/
	mut result := h.cache_get(prefix, data, cache)
	if result == '' {
		// println("MISS1")
		mut req := http.Request{}
		if query != ''{
			req = http.new_request(http.Method.get, '$h.url/api/v1/$prefix?$query', data) ?
		}else{
			req = http.new_request(http.Method.get, '$h.url/api/v1/$prefix', data) ?
		}
		req.header = h.header() ?
		println('--------------------- Request ----------------------------')
		println(req)
		res := req.do() ?
		println('--------------------- RESPONSE ----------------------------')
		println(res)
		result = res.text
	}
	// means empty result from cache
	if result == 'NULL' {
		result = ''
	}
	h.cache_set(prefix, data, result, cache) ?
	return result
}

fn (mut h CoinMarketConnection) edit_json(prefix string, id int, data string, cache bool) ?map[string]json2.Any {
	/*
	Patch Request with Json Data
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		id: id of the element.
		data: Json encoded data.
		cache: Flag to enable caching.

	Output:
		response: response Json2.Any map.
	*/
	mut req := http.new_request(http.Method.patch, '$h.url/api/v1/$prefix/$id', data) ?
	req.header = h.header() ?
	res := req.do() ?
	result := res.text
	h.cache_set(prefix, data, result, cache) ?
	data_raw := json2.raw_decode(result) ?
	data2 := data_raw.as_map()
	return data2
}

fn (mut h CoinMarketConnection) delete(prefix string, id int, cache bool) ?bool {
	/*
	Delete Request
	Inputs:
		prefix: CoinMarket elements types, ex (projects, issues, tasks, ...).
		id: id of the element.
		cache: Flag to enable caching.

	Output:
		bool: True if deleted successfully.
	*/
	mut req := http.new_request(http.Method.delete, '$h.url/api/v1/$prefix/$id', '') ?
	req.header = h.header() ?
	res := req.do() ?
	if res.status_code == 204 {
		return true
	} else {
		return false
	}
}
