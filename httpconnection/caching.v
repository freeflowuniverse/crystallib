module httpconnection

import crypto.md5
import json

// calculate the key for the cache starting from data and url
fn (mut h HTTPConnection) cache_key(args RequestArgs) string {
	encoded_url := md5.hexhash(h.url(args))
	encoded_data := md5.hexhash(args.data)
	return 'http:$h.settings.cache_key:$args.method:$encoded_url:$encoded_data'
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
