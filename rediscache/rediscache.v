

module rediscache

import redisclient

struct RedisCache {
mut:
	redis &redisclient.Redis
	namespace string
	enabled bool = true
}

pub fn newcache(namespace string) RedisCache {
	// reuse single object
	mut r:=redisclient.get_local() or {panic(err)}
	return RedisCache{redis:r,namespace:namespace}
}

pub fn (mut h RedisCache) get(key string) ?string {
	if ! h.enabled {
		return none
	}
	key2 := h.namespace+":"+key
	hit := h.redis.get('cache:$key2') or {
	    println(' [-] cache: cache miss, $key2')
		return none
	}
	return hit
}

pub fn (mut h RedisCache) set(key string, val string, expire int) ? {
	if ! h.enabled {
		return
	}	
	key2 := h.namespace+":"+key
	h.redis.set_ex('cache:$key2', val, expire.str())?
}

pub fn (mut h RedisCache) exists(key string) bool {
	h.get(key) or {
		return false
	}
	return true
}

pub fn (mut h RedisCache) reset() ? {
	key_check := "cache:"+h.namespace
	// println(key_check)
	keys := h.redis.keys(key_check)?
	// println(keys)
	for key in keys{
		// println(key)
		h.redis.del(key)?
	}
}
