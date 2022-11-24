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
pub fn get(addr string,auth string,namespace string) !ZDB {
	mut redis := redisclient.get(addr)!
	mut zdb := ZDB{
		redis: redis
	}	
	zdb.redis.send_expect_ok(['AUTH', auth])!
	mut namespaces:=zdb.redis.send_expect_list_str(['NSLIST'])!
	namespaces.map(it.to_lower())
	if !(namespace.to_lower() in namespaces){
		zdb.redis.send_expect_ok(['NSNEW', "test"])!
	}

	return zdb
}



pub fn (mut zdb ZDB) nsinfo()!string{
	//TODO: doesn't work (timur)
	i:=zdb.redis.send_expect_str(['NSINFO'])!
	return i
}