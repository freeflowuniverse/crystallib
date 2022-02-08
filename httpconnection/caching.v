module httpconnection

import crypto.md5

// calculate the key for the cache starting from data and prefix
fn (mut h HTTPConnection)  cache_key(mut args Request) string {

	mut data2 := args.postdata
	if data2.len > 16 {
		data2 = md5.hexhash(data2)
	}
	mut prefix := args.prefix
	if args.id.len>0{
		prefix += ":$args.id" 
	}
	if data2.len > 0 {
		return 'http:${h.settings.cache_key}:' + prefix + ':' + data2
	}
	return 'http:${h.settings.cache_key}:' + prefix
}


fn (mut h HTTPConnection) cache_get(mut args Request) Request{
	mut cache := h.settings.cache_enable
	if args.cache_disable{
		cache = false
	}
	if args.cache_enable{
		cache = true
	}
	if cache {
		args.result = h.redis.get(h.cache_key(mut args)) or {""}
	}
	return args
}

fn (mut h HTTPConnection) cache_set(mut args Request) ?Request {
	mut cache := h.settings.cache_enable
	if args.cache_disable{
		cache = false
	}
	if args.cache_enable{
		cache = true
	}	
	if cache {
		key := h.cache_key(mut args)
		h.redis.set(key, args.result) ?
		h.redis.expire(key, h.settings.cache_timeout) ?
	}
	return args
}

//drop the cache, if you want full cache to be empty, use prefix == ""
pub fn (mut h HTTPConnection) cache_drop(prefix string) ? {
	mut todrop := 'http:${h.settings.cache_key}:$prefix*'
	if prefix==""{
		todrop = 'http:${h.settings.cache_key}*'
	}
	all_keys := h.redis.keys(todrop) ?
	for key in all_keys {
		h.redis.del(key) ?
	}
}
