module httpconnection

import crypto.md5
import json

// calculate the key for the cache starting from data and url
fn (mut h HTTPConnection) cache_key(args RequestArgs) string {
	url := h.url(args).split('?')
	encoded_url := md5.hexhash(url[0]) // without params
	mut key := 'http:$h.settings.cache_key:$args.method:$encoded_url'
	mut req_data := args.data
	if h.settings.match_headers {
		req_data += json.encode(h.header())
	}
	req_data += if url.len > 1 { url[1] } else { '' } // add url param if exist
	key += if req_data.len > 0 { ':${md5.hexhash(req_data)}' } else { '' }
	return key
}

// Get request result from cache, return -1 if missed.
fn (mut h HTTPConnection) cache_get(args RequestArgs) ?Result {
	key := h.cache_key(args)
	mut data := h.redis.get(key) or {
		if '$err'.contains('none') {
			eprintln('cache miss!')
			return Result{
				code: -1
			}
		}
		return error('failed to get $key with error: $err')
	}
	result := json.decode(Result, data) or {
		return error('failed to decode result with error: $err')
	}
	return result
}

// Set response result in cache
fn (mut h HTTPConnection) cache_set(args RequestArgs, res Result) ? {
	key := h.cache_key(args)
	value := json.encode(res)
	println('- cache key: $key')
	println('- cache value: $value')
	h.redis.set(key, value) ?
	h.redis.expire(key, h.settings.cache_timeout) ?
}

fn (mut h HTTPConnection) cache_invalidate(args RequestArgs) ? {
	url := h.url(args).split('?')
	encoded_url := md5.hexhash(url[0])
	to_drop := 'http:$h.settings.cache_key:*:$encoded_url*'
	all_keys := h.redis.keys(to_drop) ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}

// drop the cache, if you want full cache to be empty, use prefix == ""
pub fn (mut h HTTPConnection) cache_drop(prefix string) ? {
	todrop := if prefix == '' {
		'http:$h.settings.cache_key*'
	} else {
		'http:$h.settings.cache_key:$prefix*'
	}
	all_keys := h.redis.keys(todrop) ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}
