module httpconnection

import crypto.md5
import json

// calculate the key for the cache starting from data and prefix
fn (mut h HTTPConnection) cache_key(args RequestArgs) string {
	mut key := 'http:$h.settings.cache_key:$args.prefix'
	if args.id.len > 0 {
		key += ':$args.id'
	}
	if args.data.len > 0 {
		key += if args.data.len > 16 { ':${md5.hexhash(args.data)}' } else { ':$args.data' }
	}
	return key
}

fn (mut h HTTPConnection) cache_get(mut args RequestArgs) ?Result {
	key := h.cache_key(args)
	mut data := h.redis.get(key) or {
		if '$err'.contains('none') {
			eprintln('cache miss!')
			return Result{
				code: -1
			}
		}
		return error('$err')
	}
	result := json.decode(Result, data) or {
		return error('failed to decode result with error: $err')
	}
	return result
}

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
