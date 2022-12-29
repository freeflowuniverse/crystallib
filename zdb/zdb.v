module zdb

import freeflowuniverse.crystallib.redisclient

pub struct ZDB {
pub mut:
	redis redisclient.Redis
}

// https://redis.io/topics/protocol
// examples:
//   localhost:6379
//   /tmp/redis-default.sock
pub fn get(addr string, auth string, namespace string) !ZDB {
	println(" - ZDB get: addr:$addr namespace:$namespace")
	mut redis := redisclient.get(addr)!
	mut zdb := ZDB{
		redis: redis
	}
	if auth!=""{
		zdb.redis.send_expect_ok(['AUTH', auth])!
	}
	mut namespaces := zdb.redis.send_expect_list_str(['NSLIST'])!
	namespaces.map(it.to_lower())
	if namespace.to_lower() !in namespaces {
		zdb.redis.send_expect_ok(['NSNEW', 'test'])!
	}

	return zdb
}

pub fn (mut zdb ZDB) ping() !string {
	return zdb.redis.send_expect_str(['PING'])!
}

//if key not specified will get incremental key
pub fn (mut zdb ZDB) set(key string, val string) !string {
	return zdb.redis.send_expect_str(['SET', key, val])!
}

pub fn (mut zdb ZDB) get(key string) !string {
	return zdb.redis.send_expect_str(['GET', key])!
}

pub fn (mut zdb ZDB) mget(key string) !string {
	return zdb.redis.send_expect_str(['GET', key])!
}

pub fn (mut zdb ZDB) del(key string) !string {
	return zdb.redis.send_expect_str(['DEL', key])!
}

// used only for debugging, to check memory leaks
pub fn (mut zdb ZDB) stop() !string {
	return zdb.redis.send_expect_str(['STOP'])!
}

pub fn (mut zdb ZDB) exists(key string) !string {
	return zdb.redis.send_expect_str(['EXISTS', key])!
}

pub fn (mut zdb ZDB) check(key string) !string {
	return zdb.redis.send_expect_str(['CHECK', key])!
}

pub fn (mut zdb ZDB) keycur(key string) !string {
	return zdb.redis.send_expect_str(['KEYCUR', key])!
}

pub fn (mut zdb ZDB) info() !string {
	i := zdb.redis.send_expect_str(['INFO'])!
	return i
}

pub fn (mut zdb ZDB) nsnew(namespace string) !string {
	i := zdb.redis.send_expect_str(['NSNEW', namespace])!
	return i
}

pub fn (mut zdb ZDB) nsdel(namespace string) !string {
	i := zdb.redis.send_expect_str(['NSDEL', namespace])!
	return i
}

pub fn (mut zdb ZDB) nsinfo(namespace string) !map[string]string {
	i := zdb.redis.send_expect_str(['NSINFO', namespace])!
	mut res:= map[string]string{}

	for line in i.split_into_lines(){
		if line.starts_with("#"){
			continue
		}
		if !(line.contains(":")){
			continue
		}
		splitted := line.split(":")
		key := splitted[0]
		val := splitted[1]
		res[key.trim_space()] = val.trim_space()
	}
	return res
}

pub fn (mut zdb ZDB) nslist() ![]string {
	i := zdb.redis.send_expect_list_str(['NSLIST'])!
	return i
}

pub fn (mut zdb ZDB) nssset(ns string, prop string, val string) !string {
	i := zdb.redis.send_expect_str(['NSSET', ns, prop, val])!
	return i
}

struct SelectArgs {
	namespace string
	password  string
}

pub fn (mut zdb ZDB) select_ns(args SelectArgs) !string {
	mut redis_args := ['SELECT', args.namespace]
	if args.password != '' {
		redis_args << 'SECURE'
		redis_args << args.password
	}
	i := zdb.redis.send_expect_str(redis_args)!
	return i
}

pub fn (mut zdb ZDB) dbsize() !string {
	i := zdb.redis.send_expect_str(['DBSIZE'])!
	return i
}

pub fn (mut zdb ZDB) time() !string {
	i := zdb.redis.send_expect_str(['TIME'])!
	return i
}

pub fn (mut zdb ZDB) auth(password string) !string {
	i := zdb.redis.send_expect_str(['AUTH', password])!
	return i
}

pub fn (mut zdb ZDB) auth_secure() !string {
	i := zdb.redis.send_expect_str(['AUTH', 'SECURE'])!
	return i
}

pub struct ScanArgs {
	cursor string
}

pub fn (mut zdb ZDB) scan(args ScanArgs) !string {
	mut redis_args := ['SCAN']
	if args.cursor != '' {
		redis_args << args.cursor
	}
	i := zdb.redis.send_expect_str(redis_args)!
	return i
}

// this is just an alias for SCAN
pub fn (mut zdb ZDB) scanx(args ScanArgs) !string {
	mut redis_args := ['SCANX']
	if args.cursor != '' {
		redis_args << args.cursor
	}
	i := zdb.redis.send_expect_str(redis_args)!
	return i
}

pub fn (mut zdb ZDB) rscan(args ScanArgs) !string {
	mut redis_args := ['RSCAN']
	if args.cursor != '' {
		redis_args << args.cursor
	}
	i := zdb.redis.send_expect_str(redis_args)!
	return i
}

struct WaitArgs {
	cmd     string
	timeout string = '5'
}

pub fn (mut zdb ZDB) wait(args WaitArgs) !string {
	i := zdb.redis.send_expect_str(['WAIT', args.cmd, args.timeout])!
	return i
}

struct HistoryArgs {
	key      string
	bin_data string
}

pub fn (mut zdb ZDB) history(args HistoryArgs) ![]string {
	mut redis_args := ['HISTORY', args.key]
	if args.bin_data != '' {
		redis_args << args.bin_data
	}
	i := zdb.redis.send_expect_list_str(redis_args)!
	return i
}

pub fn (mut zdb ZDB) flush() !string {
	i := zdb.redis.send_expect_str(['FLUSH'])!
	return i
}

pub fn (mut zdb ZDB) hooks() ![]string {
	i := zdb.redis.send_expect_list_str(['HOOKS'])!
	return i
}

pub fn (mut zdb ZDB) index_dirty() ![]string {
	i := zdb.redis.send_expect_list_str(['INDEX DIRTY'])!
	return i
}

pub fn (mut zdb ZDB) index_dirty_reset() !string {
	i := zdb.redis.send_expect_str(['INDEX DIRTY RESET'])!
	return i
}
