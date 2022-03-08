module httpconnection

import crypto.md5
import json

// calculate the key for the cache starting from data and url
fn (mut h HTTPConnection) cache_key(req Request) string {
	url := h.url(req).split('?')
	encoded_url := md5.hexhash(url[0]) // without params
	mut key := 'http:$h.settings.cache_key:$req.method:$encoded_url'
	mut req_data := req.data
	if h.settings.match_headers {
		req_data += json.encode(h.header())
	}
	req_data += if url.len > 1 { url[1] } else { '' } // add url param if exist
	key += if req_data.len > 0 { ':${md5.hexhash(req_data)}' } else { '' }
	return key
}

// Get request result from cache, return -1 if missed.
fn (mut h HTTPConnection) cache_get(req Request) ?Result {
	key := h.cache_key(req)
	mut data := h.redis.get(key) or {
		if '$err'.contains('none') {
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
fn (mut h HTTPConnection) cache_set(req Request, res Result) ? {
	key := h.cache_key(req)
	value := json.encode(res)
	h.redis.set(key, value) ?
	h.redis.expire(key, h.settings.cache_timeout) ?
}

// Invalidate cache for specific url
fn (mut h HTTPConnection) cache_invalidate(req Request) ? {
	url := h.url(req).split('?')
	encoded_url := md5.hexhash(url[0])
	to_drop := 'http:$h.settings.cache_key:*:$encoded_url*'
	all_keys := h.redis.keys(to_drop) ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}

// drop full cache for specific cache_key
pub fn (mut h HTTPConnection) cache_drop() ? {
	todrop := 'http:$h.settings.cache_key*'
	all_keys := h.redis.keys(todrop) ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}
