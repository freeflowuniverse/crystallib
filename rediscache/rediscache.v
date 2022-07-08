module rediscache

import freeflowuniverse.crystallib.appsbox.redisapp
import freeflowuniverse.crystallib.redisclient

struct RedisCache {
mut:
	redis     &redisclient.Redis
	namespace string
	enabled   bool = true
}

pub fn newcache(namespace string) RedisCache {
	// reuse single object
	mut r := redisapp.client_local_get() or { panic(err) }
	// mut r := redisclientcore.get() or { panic(err) }
	return RedisCache{
		redis: r
		namespace: namespace
	}
}

pub fn (mut h RedisCache) get(key string) ?string {
	if !h.enabled {
		return none
	}
	key2 := h.namespace + ':' + key
	hit := h.redis.get('cache:$key2') or {
		println('[-] cache: cache miss, $key2')
		return none
	}

	println('[+] cache: cache hit: $key2')
	return hit
}

pub fn (mut h RedisCache) set(key string, val string, expire int) ? {
	if !h.enabled {
		return
	}

	key2 := h.namespace + ':' + key
	h.redis.set_ex('cache:$key2', val, expire.str())?
}

pub fn (mut h RedisCache) exists(key string) bool {
	h.get(key) or { return false }
	return true
}

pub fn (mut h RedisCache) reset() ? {
	key_check := 'cache:' + h.namespace
	// println(key_check)
	keys := h.redis.keys(key_check)?
	// println(keys)
	for key in keys {
		// println(key)
		h.redis.del(key)?
	}
}
