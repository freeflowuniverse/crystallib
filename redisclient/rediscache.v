module rediscache

// import appsbox.redisapp
import freeflowuniverse.crystallib.redisclient

pub struct RedisCache {
mut:
	redis     &redisclient.Redis
	namespace string
	enabled   bool = true
}

pub fn (mut r redisclient.Redis )cache(namespace string) RedisCache {
	return RedisCache{
		redis: &r
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
