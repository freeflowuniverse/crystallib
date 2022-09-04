import freeflowuniverse.crystallib.redisclient
import time
// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:

fn setup() &redisclient.Redis {
	mut redis := redisclient.core_get()
	// Select db 10 to be away from default one '0'
	redis.selectdb(10) or { panic(err) }
	return redis
}

fn cleanup(mut redis redisclient.Redis) ? {
	redis.flushall()?
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

fn test_large_value() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	rr := 'SSS' + 'a'.repeat(40000) + 'EEE'
	mut rr2 := ''
	for i in 0 .. 50 {
		redis.set('test_large_value0', rr) or { panic(err) }
		rr2 = redis.get('test_large_value0') or { panic(err) }
		assert rr.len == rr2.len
		assert rr == rr2
	}
	for i3 in 0 .. 100 {
		redis.set('test_large_value$i3', rr) or { panic(err) }
	}
	for i4 in 0 .. 100 {
		rr4 := redis.get('test_large_value$i4') or { panic(err) }
		assert rr.len == rr4.len
		redis.del('test_large_value$i4') or { panic(err) }
	}
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
	redis.set('test3', '12') or { panic(err) }
	redis.set('test4', '34') or { panic(err) }
	redis.set('test5', '56') or { panic(err) }
	redis.set('test6', '78') or { panic(err) }
	redis.set('test7', '9') or { panic(err) }
	cursor, data := redis.scan(0) or { panic(err) }
	println(data)
	assert cursor == '0'
}

fn test_set_opts() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	assert redis.set_opts('test8', '123', redisclient.SetOpts{
		ex: 2
	}) == true
	assert redis.set_opts('test8', '456', redisclient.SetOpts{
		px: 2000
		xx: true
	}) == true
	assert redis.set_opts('test8', '789', redisclient.SetOpts{
		px: 1000
		nx: true
	}) == false
	// Works with redis version > 6
	assert redis.set_opts('test8', '012', redisclient.SetOpts{ keep_ttl: true }) == true
}

fn test_setex() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.setex('test9', 2, '123') or { panic(err) }
	mut r := redis.get('test9') or {
		assert false
		return
	}
	assert r == '123'

	time.sleep(2100 * time.millisecond)
	r = redis.get('test9') or {
		assert true
		return
	}
	assert false
}

fn test_psetex() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.psetex('test10', 200, '123') or { panic(err) }
	mut r := redis.get('test10') or {
		assert false
		return
	}
	assert r == '123'

	time.sleep(220 * time.millisecond)
	r = redis.get('test10') or {
		assert true
		return
	}
	assert false
}

fn test_setnx() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	mut r1 := redis.setnx('test11', '123') or { panic(err) }
	assert r1 == 1
	r1 = redis.setnx('test11', '456') or { panic(err) }
	assert r1 == 0

	val := redis.get('test11') or {
		assert false
		return
	}
	assert val == '123'
}

fn test_incrby() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}

	redis.set('test12', '100') or { panic(err) }
	r1 := redis.incrby('test12', 4) or {
		assert false
		return
	}
	assert r1 == 104

	r2 := redis.incrby('test13', 2) or {
		assert false
		return
	}
	assert r2 == 2

	redis.set('test14', 'nan') or { panic(err) }
	redis.incrby('test14', 1) or {
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
	redis.set('test15', '100') or { panic(err) }
	r1 := redis.incr('test15') or {
		assert false
		return
	}
	assert r1 == 101

	r2 := redis.incr('test16') or {
		assert false
		return
	}
	assert r2 == 1

	redis.set('test17', 'nan') or { panic(err) }
	redis.incr('test17') or {
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
	redis.set('test18', '100') or { panic(err) }
	r1 := redis.decr('test18') or {
		assert false
		return
	}
	assert r1 == 99

	r2 := redis.decr('test19') or {
		assert false
		return
	}
	assert r2 == -1

	redis.set('test20', 'nan') or { panic(err) }
	redis.decr('test20') or {
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
	redis.set('test21', '100') or { panic(err) }
	r1 := redis.decrby('test21', 4) or {
		assert false
		return
	}
	assert r1 == 96

	r2 := redis.decrby('test22', 2) or {
		assert false
		return
	}
	assert r2 == -2

	redis.set('test23', 'nan') or { panic(err) }
	redis.decrby('test23', 1) or {
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
	redis.set('test24', '3.1415') or { panic(err) }
	r1 := redis.incrbyfloat('test24', 3.1415) or {
		assert false
		return
	}
	assert r1 == 6.283

	r2 := redis.incrbyfloat('test25', 3.14) or {
		assert false
		return
	}
	assert r2 == 3.14

	r3 := redis.incrbyfloat('test25', -3.14) or {
		assert false
		return
	}
	assert r3 == 0

	redis.set('test26', 'nan') or { panic(err) }
	redis.incrbyfloat('test26', 1.5) or {
		assert true
		return
	}
	assert false
}

fn test_append() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test27', 'bac') or { panic(err) }
	r1 := redis.append('test27', 'on') or {
		assert false
		return
	}
	assert r1 == 5

	r2 := redis.get('test27') or {
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
	r := redis.lpush('test28', 'item 1') or {
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
	r := redis.rpush('test29', 'item 1') or {
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
	r1 := redis.setrange('test30', 0, 'bac') or {
		assert false
		return
	}
	assert r1 == 3

	r2 := redis.setrange('test30', 3, 'on') or {
		assert false
		return
	}
	assert r2 == 5
}

fn test_expire() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.expire('test31', 2) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test31', '123') or { panic(err) }
	r2 := redis.expire('test31', 2) or {
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
	r1 := redis.pexpire('test32', 200) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test32', '123') or { panic(err) }
	r2 := redis.pexpire('test32', 200) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_expireat() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.expireat('test33', 1293840000) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test33', '123') or { panic(err) }
	r2 := redis.expireat('test33', 1293840000) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_pexpireat() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.pexpireat('test34', 1555555555005) or {
		assert false
		return
	}
	assert r1 == 0

	redis.set('test34', '123') or { panic(err) }
	r2 := redis.pexpireat('test34', 1555555555005) or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_persist() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.persist('test35') or {
		assert false
		return
	}
	assert r1 == 0
	redis.setex('test35', 2, '123') or { panic(err) }
	r2 := redis.persist('test35') or {
		assert false
		return
	}
	assert r2 == 1
}

fn test_get() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test36', '123') or { panic(err) }
	mut r := redis.get('test36') or {
		assert false
		return
	}
	assert r == '123'
	assert helper_get_key_not_found(mut redis, 'test37') == true
}

fn test_getset() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	mut r1 := redis.getset('test38', '10') or { '' }
	assert r1 == ''

	r2 := redis.getset('test38', '15') or {
		assert false
		return
	}
	assert r2 == '10'

	r3 := redis.get('test38') or {
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
	redis.set('test39', 'community') or { panic(err) }
	r1 := redis.getrange('test39', 4, -1) or {
		assert false
		return
	}
	assert r1 == 'unity'

	r2 := redis.getrange('test40', 0, -1) or {
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
	redis.set('test41', '123') or { panic(err) }
	r2 := redis.randomkey() or {
		assert false
		return
	}
	assert r2 == 'test41'
	assert helper_get_key_not_found(mut redis, 'test42') == true
}

fn test_strlen() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test43', 'bacon') or { panic(err) }
	r1 := redis.strlen('test43') or {
		assert false
		return
	}
	assert r1 == 5

	r2 := redis.strlen('test44') or {
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
	redis.lpush('test45', '123') or {
		assert false
		return
	}
	r1 := redis.lpop('test45') or {
		assert false
		return
	}
	assert r1 == '123'
	assert helper_lpop_key_not_found(mut redis, 'test46') == true
}

fn test_rpop() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.lpush('test47', '123') or {
		assert false
		return
	}
	r1 := redis.rpop('test47') or {
		assert false
		return
	}
	assert r1 == '123'
	assert helper_rpop_key_not_found(mut redis, 'test48') == true
}

fn test_llen() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.lpush('test49', '123') or {
		assert false
		return
	}
	r2 := redis.llen('test49') or {
		assert false
		return
	}
	assert r2 == r1

	r3 := redis.llen('test50') or {
		assert false
		return
	}
	assert r3 == 0

	redis.set('test51', 'not a list') or { panic(err) }
	redis.llen('test51') or {
		assert true
		return
	}
	assert false
}

fn test_ttl() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.setex('test52', 15, '123') or { panic(err) }
	r1 := redis.ttl('test52') or {
		assert false
		return
	}
	assert r1 == 15

	redis.set('test53', '123') or { panic(err) }
	r2 := redis.ttl('test53') or {
		assert false
		return
	}
	assert r2 == -1

	r3 := redis.ttl('test54') or {
		assert false
		return
	}
	assert r3 == -2
}

fn test_pttl() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.psetex('test55', 1500, '123') or { panic(err) }
	r1 := redis.pttl('test55') or {
		assert false
		return
	}
	assert r1 >= 1490 && r1 <= 1500

	redis.set('test56', '123') or { panic(err) }
	r2 := redis.pttl('test56') or {
		assert false
		return
	}
	assert r2 == -1

	r3 := redis.pttl('test57') or {
		assert false
		return
	}
	assert r3 == -2
}

fn test_exists() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	r1 := redis.exists('test58') or {
		assert false
		return
	}
	assert r1 == false

	redis.set('test59', '123') or { panic(err) }
	r2 := redis.exists('test59') or {
		assert false
		return
	}
	assert r2 == true
}

fn test_type_of() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	_ := redis.type_of('test60') or {
		assert true
		return
	}

	redis.set('test61', '123') or { panic(err) }
	mut r := redis.type_of('test61') or {
		assert false
		return
	}
	assert r == 'string'

	_ := redis.lpush('test62', '123') or { panic(err) }
	r = redis.type_of('test62') or {
		assert false
		return
	}
	assert r == 'list'
}

fn test_del() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test63', '123') or { panic(err) }
	c := redis.del('test63') or {
		assert false
		return
	}
	assert c == 1
	assert helper_get_key_not_found(mut redis, 'test63') == true
}

fn test_rename() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.rename('test64', 'test65') or { println('key not found') }
	redis.set('test64', 'will be 65') or { panic(err) }
	redis.rename('test64', 'test65') or { panic(err) }
	r := redis.get('test65') or {
		assert false
		return
	}
	assert r == 'will be 65'
}

fn test_renamenx() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	assert helper_renamenx_err_helper(mut redis, 'test66', 'test67') == 'no such key'
	redis.set('test68', '123') or { panic(err) }
	redis.set('test66', 'will be 67') or { panic(err) }
	r1 := redis.renamenx('test66', 'test67') or {
		assert false
		return
	}
	assert r1 == 1

	r2 := redis.get('test67') or {
		assert false
		return
	}
	assert r2 == 'will be 67'

	r3 := redis.renamenx('test67', 'test68') or {
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
	redis.set('test69', '123') or { panic(err) }
	redis.flushall() or { panic(err) }
	assert helper_get_key_not_found(mut redis, 'test69') == true
}

fn test_keys() {
	mut redis := setup()
	defer {
		cleanup(mut redis) or { panic(err) }
	}
	redis.set('test70:1', '1') or { panic(err) }
	redis.set('test70:2', '2') or { panic(err) }
	r1 := redis.keys('test70:*') or {
		assert false
		return
	}
	assert r1.len == 2
}

fn helper_get_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.get(key) or {
		if err.msg() == 'key not found' || err.msg() == '' {
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_randomkey_database_empty(mut redis redisclient.Redis) bool {
	redis.randomkey() or {
		if err.msg() == 'database is empty' || err.msg() == '' {
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_renamenx_err_helper(mut redis redisclient.Redis, key string, newkey string) string {
	redis.renamenx(key, newkey) or { return 'no such key' }
	return ''
}

fn helper_lpop_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.lpop(key) or {
		if err.msg() == 'key not found' || err.msg() == '' {
			return true
		} else {
			return false
		}
	}
	return false
}

fn helper_rpop_key_not_found(mut redis redisclient.Redis, key string) bool {
	redis.rpop(key) or {
		if err.msg() == 'key not found' || err.msg() == '' {
			return true
		} else {
			return false
		}
	}
	return false
}
