/*
METHODS NOTES
 * Our target to wrap the default http methods used in V to be cached using redis
 * By default cache enabled in all Request, if you need to disable cache, set req.cache_disable true
 *
 * Flow will be:
 * 1 - Check cache if enabled try to get result from cache
 * 2 - Check result
 * 3 - Do request, if needed
 * 4 - Set in cache if enabled or invalidate cache
 * 5 - Return result

 Suggestion: Send function now enough to do what we want, no need to any post*, get* additional functions
*/

module httpconnection

import x.json2
import net.http
import despiegk.crystallib.crystaljson

// Build url from Request and httpconnection
fn (mut h HTTPConnection) url(req Request) string {
	mut u := '$h.base_url/${req.prefix.trim('/')}'
	if req.id.len > 0 {
		u += '/$req.id'
	}
	if req.params.len > 0 {
		u += '?${http.url_encode_form_data(req.params)}'
	}
	return u
}

// Join headers from httpconnection and Request
fn (mut h HTTPConnection) header(req Request) http.Header {
	return h.default_header.join(req.header)
}

// Return if request cacheable, depeds on connection cache and request arguments.
fn (h HTTPConnection) is_cacheable(req Request) bool {
	return !(h.cache.disable || req.cache_disable)
		&& req.method in h.cache.allowable_methods
}

// Return true if we need to invalidate cache after unsafe method
fn (h HTTPConnection) needs_invalidate(req Request, result_code int) bool {
	return !(h.cache.disable || req.cache_disable) && req.method in unsafe_http_methods
		&& req.method !in h.cache.allowable_methods && result_code >= 200
		&& result_code <= 399
}

// Core fucntion to be used in all other function
pub fn (mut h HTTPConnection) send(req Request) ?Result {
	mut result := Result{}
	mut response := http.Response{}
	mut err_message := ''
	mut from_cache := false // used to know if result came from cache
	is_cacheable := h.is_cacheable(req)
	// 1 - Check cache if enabled try to get result from cache
	if is_cacheable {
		result = h.cache_get(req) ?
		if result.code != -1 {
			from_cache = true
		}
	}
	// 2 - Check result
	if result.code in [0, -1] {
		// 3 - Do request, if needed
		url := h.url(req)
		mut new_req := http.new_request(req.method, url, req.data) ?
		// joining the header from the HTTPConnection with the one from Request
		new_req.header = h.header()
		for i in 0..h.retry {
			response = new_req.do() or {
				err_message = "$err"
				println(err_message)
				continue
			}
			break
		}
		if response.status_code == 0 {
			return error(err_message)
		}
		result.code = response.status_code
		result.data = response.text
	}

	// 4 - Set in cache if enabled
	if !from_cache && is_cacheable && result.code in h.cache.allowable_codes {
		h.cache_set(req, result) ?
	}

	if h.needs_invalidate(req, result.code) {
		h.cache_invalidate(req) ?
	}

	// 5 - Return result
	return result
}

pub fn (r Result) is_ok() bool {
	return r.code >= 200 && r.code <= 399 
}

[deprecated]
pub fn (mut h HTTPConnection) post_json_str(mut req Request) ?string {
	req.method = .post
	result := h.send(req) ?
	return result.data
}

[deprecated]
pub fn (mut h HTTPConnection) get_json_dict(mut req Request) ?map[string]json2.Any {
	data_ := h.get_json_str(mut req) ?
	mut data := map[string]json2.Any{}

	data = crystaljson.json_dict_filter_any(data_, false, [], []) ?
	return data
}

[deprecated]
pub fn (mut h HTTPConnection) get_json_list(mut req Request) ?[]string {
	mut data_ := h.get_json_str(mut req) ?
	if req.dict_key.len > 0 {
		data_ = crystaljson.json_dict_get_string(data_, false, req.dict_key) ?
	}
	data := crystaljson.json_list(data_, false)
	return data
}

// Get Request with json data and return response as string
[deprecated]
pub fn (mut h HTTPConnection) get_json_str(mut req Request) ?string {
	req.method = .get
	result := h.send(req) ?
	return result.data
}
