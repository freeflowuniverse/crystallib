import redisclient
// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:

fn setup() redisclient.Redis {
	mut redis := redisclient.connect('localhost:6379') or { panic(err) }
	// Select db 10 to be away from default one '0'
	redis.selectdb(10) or {panic(err)}
	return redis
}

fn cleanup(mut redis redisclient.Redis) ? {
	redis.flushall() ?
	redis.disconnect()
}

fn test_set() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	// println('start')
	// for _ in 0 .. 10000 {
	// 	redis.set('test0', '123') or { panic(err) }
	// }
	println('stop')
	redis.set('test0', '456') or { panic(err) }
	res := redis.get('test0') or { panic(err) }
	assert res == '456'

	redis.hset('x', 'a', '222') or { panic(err) }
	redis.hset('x', 'b', '333') or { panic(err) }
	mut res3 := redis.hget('x', 'b') or { panic(err) }
	assert res3 == '333'
	redis.hdel('x', 'b') or { panic(err) }
	res3 = redis.hget('x', 'b') or { 'NOTHING' }
	assert res3 == 'NOTHING'
	e := redis.hexists('x', 'a') or { panic(err) }
	assert e
}

fn test_queue() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	mut q := redis.queue_get('kds:q')
	q.add('test1') or { panic(err) }
	q.add('test2') or { panic(err) }
	mut res := q.get(1) or { panic(err) }
	assert res == 'test1'
	res = q.get(1) or { panic(err) }
	assert res == 'test2'
	println('start')
	res = q.get(100) or { '' }
	println('stop')
	assert res == ''
	println(res)
}

fn test_scan() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	println('stop')
	redis.set('testscan0', '12') or { panic(err) }
	redis.set('testscan1', '34') or { panic(err) }
	redis.set('testscan2', '56') or { panic(err) }
	redis.set('testscan3', '78') or { panic(err) }
	redis.set('testscan4', '9') or { panic(err) }
	cursor, data :=redis.scan(0) or { panic(err) }
	println(data)
	assert cursor == "0"
	println("Scanned")
}

// TODO: need all the other tests done

// fn test_set_opts() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis)
// 	}
// 	assert redis.set_opts('test5', '123', redisclient.SetOpts{
// 		ex: 2
// 	}) == true
// 	assert redis.set_opts('test5', '456', redisclient.SetOpts{
// 		px: 2000
// 		xx: true
// 	}) == true
// 	assert redis.set_opts('test5', '789', redisclient.SetOpts{
// 		px: 1000
// 		nx: true
// 	}) == false
// 	// assert redis.set_opts('test5', '012', redisclient.SetOpts{ keep_ttl: true }) == true //disabled because I don't have redis >= 6 to testit
// }

// fn test_setex() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis)
// 	}
// 	assert redis.setex('test6', 2, '123') == true
// }

// fn test_psetex() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis)
// 	}
// 	assert redis.psetex('test7', 2000, '123') == true
// }

// fn test_setnx() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis)
// 	}
// 	assert redis.setnx('test8', '123') == 1
// 	assert redis.setnx('test8', '456') == 0
// }

fn test_incrby() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}

	redis.set('test20', '100') or { panic(err) }
	r1 := redis.incrby('test20', 4) or {
		assert false
		return
	}
	assert r1 == 104

	r2 := redis.incrby('test21', 2) or {
		assert false
		return
	}
	assert r2 == 2

	redis.set('test23', 'nan') or { panic(err) }
	redis.incrby('test23', 1) or {
		assert true
		return
	}
	assert false
}

fn test_incr() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test24', '100') or { panic(err) }
	r1 := redis.incr('test24') or {
		assert false
		return
	}
	assert r1 == 101
	
	r2 := redis.incr('test25') or {
		assert false
		return
	}
	assert r2 == 1
	
	redis.set('test26', 'nan') or { panic(err) }
	redis.incr('test26') or {
		assert true
		return
	}
	assert false
}

fn test_decr() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test27', '100') or { panic(err) }
	r1 := redis.decr('test27') or {
		assert false
		return
	}
	assert r1 == 99

	r2 := redis.decr('test28') or {
		assert false
		return
	}
	assert r2 == -1

	redis.set('test29', 'nan') or { panic(err) }
	redis.decr('test29') or {
		assert true
		return
	}
	assert false
}

fn test_decrby() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test30', '100') or { panic(err) }
	r1 := redis.decrby('test30', 4) or {
		assert false
		return
	}
	assert r1 == 96

	r2 := redis.decrby('test31', 2) or {
		assert false
		return
	}
	assert r2 == -2

	redis.set('test32', 'nan') or { panic(err) }
	redis.decrby('test32', 1) or {
		assert true
		return
	}
	assert false
}

fn test_incrbyfloat() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test33', '3.1415') or { panic(err) }
	r1 := redis.incrbyfloat('test33', 3.1415) or {
		assert false
		return
	}
	assert r1 == 6.283

	r2 := redis.incrbyfloat('test34', 3.14) or {
		assert false
		return
	}
	assert r2 == 3.14

	r3 := redis.incrbyfloat('test34', -3.14) or {
		assert false
		return
	}
	assert r3 == 0

	redis.set('test35', 'nan') or { panic(err) }
	redis.incrbyfloat('test35', 1.5) or {
		assert true
		return
	}
	assert false
}

fn test_append() {
	mut redis := setup()
	defer {
		cleanup(mut redis)  or { panic(err) }
	}
	redis.set('test48', 'bac')  or { panic(err) }
	r1 := redis.append('test48', 'on') or {
		assert false
		return
	}
	assert r1 == 5

	r2 := redis.get('test48') or {
		assert false
		return
	}
	assert r2 == 'bacon'
}

fn test_lpush() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r := redis.lpush('test53', 'item 1') or {
		assert false
		return
	}
	assert r == 1
}

fn test_rpush() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r := redis.rpush('test59', 'item 1') or {
		assert false
		return
	}
	assert r == 1
}

fn test_setrange() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.setrange('test52', 0, 'bac') or {
		assert false
		return
	}
	assert r1 == 3

	r2 := redis.setrange('test52', 3, 'on') or {
		assert false
		return
	}
	assert r2 == 5
}

fn test_expire() {
	mut redis := setup()
	defer {
		cleanup(mut redis)  or { panic(err) }
	}
	r1 := redis.expire('test10', 2) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test10', '123') or { panic(err) }
	r2 := redis.expire('test10', 2) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_pexpire() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.pexpire('test11', 200) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test11', '123')  or { panic(err) }
	r2 := redis.pexpire('test11', 200) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_expireat() {
	mut redis := setup()
	defer {
		cleanup(mut redis)  or { panic(err) }
	}
	r1 := redis.expireat('test12', 1293840000) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test12', '123')  or { panic(err) }
	r2 := redis.expireat('test12', 1293840000) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_pexpireat() {
	mut redis := setup()
	defer {
		cleanup(mut redis)  or { panic(err) }
	}
	r1 := redis.pexpireat('test13', 1555555555005) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test13', '123')  or { panic(err) }
	r2 := redis.pexpireat('test13', 1555555555005) or {
		assert false
		return
	}
	assert r2 == 1
}

// fn test_persist() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis) or { panic(err) }
// 	}
// 	r1 := redis.persist('test46') or {
// 		assert false
// 		return
// 	}
// 	assert r1 == 0
// 	assert redis.setex('test46', 2, '123') == true
// 	r2 := redis.persist('test46') or {
// 		assert false
// 		return
// 	}
// 	assert r2 == 1
// }

fn test_get() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test2', '123') or { panic(err) }
	mut r := redis.get('test2') or {
		assert false
		return
	}
	assert r == '123'
	assert helper_get_key_not_found(mut redis, 'test3') == true
}

fn test_getset() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	mut r1 := redis.getset('test36', '10') or { '' } 
	assert r1 == ''

	r2 := redis.getset('test36', '15') or {
		assert false
		return
	}
	assert r2 == '10'

	r3 := redis.get('test36') or {
		assert false
		return
	}
	assert r3 == '15'
}

fn test_getrange() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test50', 'community') or { panic(err) }
	r1 := redis.getrange('test50', 4, -1) or {
		assert false
		return
	}
	assert r1 == 'unity'

	r2 := redis.getrange('test51', 0, -1) or {
		assert false
		return
	}
	assert r2 == ''
}

fn test_randomkey() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	assert helper_randomkey_database_empty(mut redis) == true
	redis.set('test47', '123') or { panic(err) }
	r2 := redis.randomkey() or {
		assert false
		return
	}
	assert r2 == 'test47'
	assert helper_get_key_not_found(mut redis, 'test3') == true
}

fn test_strlen() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test49', 'bacon') or { panic(err) }
	r1 := redis.strlen('test49') or {
		assert false
		return
	}
	assert r1 == 5

	r2 := redis.strlen('test50') or {
		assert false
		return
	}
	assert r2 == 0
}

fn test_lpop() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.lpush('test54', '123') or {
		assert false
		return
	}
	r1 := redis.lpop('test54') or {
		assert false
		return
	}
	assert r1 == '123'
	assert helper_lpop_key_not_found(mut redis, 'test55') == true
}

fn test_rpop() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.lpush('test60', '123') or {
		assert false
		return
	}
	r1 := redis.rpop('test60') or {
		assert false
		return
	}
	assert r1 == '123'
	assert helper_rpop_key_not_found(mut redis, 'test61') == true
}

fn test_llen() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.lpush('test56', '123') or {
		assert false
		return
	}
	r2 := redis.llen('test56') or {
		assert false
		return
	}
	assert r2 == r1

	r3 := redis.llen('test57') or {
		assert false
		return
	}
	assert r3 == 0

	redis.set('test58', 'not a list') or { panic(err) }
	redis.llen('test58') or {
		assert true
		return
	}
	assert false
}

// fn test_ttl() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis) or { panic(err) }
// 	}
// 	assert redis.setex('test14', 15, '123') == true
// 	r1 := redis.ttl('test14') or {
// 		assert false
// 		return
// 	}
// 	assert r1 == 15
// 	assert redis.set('test15', '123') == true
// 	r2 := redis.ttl('test15') or {
// 		assert false
// 		return
// 	}
// 	assert r2 == -1
// 	r3 := redis.ttl('test16') or {
// 		assert false
// 		return
// 	}
// 	assert r3 == -2
// }

// fn test_pttl() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis) or { panic(err) }
// 	}
// 	assert redis.psetex('test17', 1500, '123') == true
// 	r1 := redis.pttl('test17') or {
// 		assert false
// 		return
// 	}
// 	assert r1 >= 1490 && r1 <= 1500
// 	assert redis.set('test18', '123') == true
// 	r2 := redis.pttl('test18') or {
// 		assert false
// 		return
// 	}
// 	assert r2 == -1
// 	r3 := redis.pttl('test19') or {
// 		assert false
// 		return
// 	}
// 	assert r3 == -2
// }

fn test_exists() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.exists('test37') or {
		assert false
		return
	}
	assert r1 == false

	redis.set('test38', '123') or { panic(err) }
	r2 := redis.exists('test38') or {
		assert false
		return
	}
	assert r2 == true
}

// fn test_type_of() {
// 	mut redis := setup()
// 	defer {
// 		cleanup(mut redis) or { panic(err) }
// 	}
// 	r1 := redis.type_of('test39') or {
// 		assert false
// 		return
// 	}
// 	assert r1 == .t_none
// 	assert redis.set('test40', '123') == true
// 	r2 := redis.type_of('test40') or {
// 		assert false
// 		return
// 	}
// 	assert r2 == .t_string
// }

fn test_del() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test4', '123') or { panic(err) }
	c := redis.del('test4') or {
		assert false
		return
	}
	assert c == 1
	assert helper_get_key_not_found(mut redis, 'test4') == true
}

fn test_rename() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.rename('test41', 'test42') or { println("key not found") }
	redis.set('test41', 'will be 42') or { panic(err) }
	redis.rename('test41', 'test42') or { panic(err) }
	r := redis.get('test42') or {
		assert false
		return
	}
	assert r == 'will be 42'
}

fn test_renamenx() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	assert helper_renamenx_err_helper(mut redis, 'test43', 'test44') == 'no such key'
	redis.set('test45', '123') or { panic(err) }
	redis.set('test43', 'will be 44')or { panic(err) }
	r1 := redis.renamenx('test43', 'test44') or {
		assert false
		return
	}
	assert r1 == 1

	r2 := redis.get('test44') or {
		assert false
		return
	}
	assert r2 == 'will be 44'

	r3 := redis.renamenx('test44', 'test45') or {
		assert false
		return
	}
	assert r3 == 0
}

fn test_flushall() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test9', '123') or { panic(err) }
	redis.flushall() or { panic(err) }
	assert helper_get_key_not_found(mut redis, 'test9') == true
}

fn helper_get_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.get(key) or {
		if err.msg == 'key not found' || err.msg == '' {
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_randomkey_database_empty(mut redis redisclient.Redis) bool {
	redis.randomkey() or {
		if err.msg == 'database is empty' || err.msg == ''{
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_renamenx_err_helper(mut redis redisclient.Redis, key string, newkey string) string {
	redis.renamenx(key, newkey) or { return "no such key" }
	return ''
}

fn helper_lpop_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.lpop(key) or {
		if err.msg == 'key not found' || err.msg == '' {
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_rpop_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.rpop(key) or {
		if err.msg == 'key not found' || err.msg == '' {
			return true
		} else {
			return false
		}
	}
	return false
}
