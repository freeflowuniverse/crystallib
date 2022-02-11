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


//resultcode >0 if error
//resultcode = 999998 was not in cache, but we don't know on source
//resultcode = 999999 if empty (from source or was in cache)
fn (mut h HTTPConnection) cache_get(mut args Request) Request{
	mut cache := h.settings.cache_enable
	if args.cache_disable{
		cache = false
	}
	if args.cache_enable{
		cache = true
	}
	if cache {
		//if not there then empty, not in cache
		mut data := h.redis.get(h.cache_key(mut args)) or {
			"999998|"
			}
		if data.trim(" \n")==""{
			data = "999998|"
		}
		if ! (data.contains("|")){
			panic("bug, data should have |.\n***\n$data\n***")
		}
		// println("***$data***")
		datasplitted := data.split_nth("|",2)
		if datasplitted.len!=2{
			panic("bug, data should always be 2 parts.\n$data")
		}
		args.result_code = datasplitted[0].int()
		args.result = datasplitted[1]
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
		data := "${args.result_code}|${args.result}"
		h.redis.set(key, data) ?
		h.redis.expire(key, h.settings.cache_timeout) ?
	}
	return args
}

//drop the cache, if you want full cache to be empty, use prefix == ""
pub fn (mut h HTTPConnection) cache_drop(prefix string) ? {
	mut todrop := 'http:${h.settings.cache_key}:$prefix*'
	if prefix==""{
		todrop = 'http:${h.settings.cache_key}*'
		// println("delete cache: $todrop")
		h.redis.del('http:${h.settings.cache_key}') ?
	}
	all_keys := h.redis.keys(todrop) ?
	for key in all_keys {
		// println("delete subkey: $key")
		h.redis.del(key) ?
	}
	
}
