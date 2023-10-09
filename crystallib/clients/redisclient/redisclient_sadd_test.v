import freeflowuniverse.crystallib.clients.redisclient

fn setup() !&redisclient.Redis {
	mut redis := redisclient.core_get()!
	redis.selectdb(10) or { panic(err) }
	return &redis
}

fn cleanup(mut redis redisclient.Redis) ! {
	redis.flushall()!
	// redis.disconnect()
}

fn test_sadd() {
	mut redis := setup()!
	defer {
		cleanup(mut redis) or { panic(err) }
	}

	redis.sadd('mysadd', ['a', 'b', 'c']) or { panic(err) }
	r := redis.smismember('mysadd', ['a', 'b', 'c']) or { panic(err) }
	assert r == [1, 1, 1]
	r2 := redis.smismember('mysadd', ['a', 'd', 'c']) or { panic(err) }
	assert r2 == [1, 0, 1]
}
