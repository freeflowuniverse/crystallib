

module rediscache

import redisclient

struct RedisConnection {
mut:
	redis redisclient.Redis
}

fn init_single_redis() RedisConnection {
	return RedisConnection{
		redis: redisclient.connect('127.0.0.1:6379') or { redisclient.Redis{} }
	}
}

struct RedisCache {
mut:
	redis &redisclient.Redis
	namespace string
	enabled bool = true
}

const redisconnection = init_single_redis()

pub fn newcache(namespace string) RedisCache {
	// reuse single object
	return RedisCache{redis:&redisconnection.redis,namespace:namespace}
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
