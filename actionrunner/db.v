module actionrunner

import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.params
import json

pub struct DB{
pub mut:
	redis redisclient.Redis
}

pub fn new_db() !DB{
	mut redis := redisclient.core_get()
	mut db:=DB{redis:redis}
	return db
}

//set params per domain based on id, is in redis
pub fn (mut db DB) set(domain string, model string, id u32, params params.Params)!{
	data:=json.encode(params)
	db.redis.hset("actiondb.${domain}.${model}","$id", data)!
}

//get params per domain based on id
pub fn (mut db DB) get(domain string,model string, id u32)!params.Params{
	data:=db.redis.hget("actiondb.${domain}.${model}","$id")!
	mut params := json.decode(params.Params, data)!
	return params
}

//delete an entry
pub fn (mut db DB) delete(domain string,model string, id u32)!{
	db.redis.hdel("actiondb.${domain}.${model}","$id")!
}


//create secondary table with keys e.g. to go from name to id
pub fn (mut db DB) key_set(domain string, model string, key string, id u32)!{
	db.redis.hset("actiondbkeys.${domain}.${model}",key,"$id")!
}

//get a key from the keys db
pub fn (mut db DB) key_get(domain string, model string, key string)!u32{
	data:=db.redis.hget("actiondbkeys.${domain}.${model}",key)!
	return data.u32()
}

pub fn (mut db DB) key_delete(domain string, model string, key string)!{
	db.redis.hdel("actiondbkeys.${domain}.${model}",key)!
	return
}


//delete al keys for a certain domain
pub fn (mut db DB) keys_get(domain string, model string, prefix string)![]u32{
	mut keys:=db.redis.hkeys("actiondbkeys.${domain}.${model}")!
	mut res:=[]u32{}
	for key in keys{
		if key.starts_with(prefix){
			data:=db.redis.hget("actiondbkeys.${domain}.${model}",key)!
			res << data.u32()
		}		
	}
	return res
}


//delete al keys for a certain domain
pub fn (mut db DB) keys_delete_domain(domain string)!{
	mut keys:=db.redis.hkeys("actiondbkeys.${domain}")!
	for key in keys{
		db.redis.hdel("actiondbkeys.${domain}",key)!
	}
}

pub fn (mut db DB) keys_delete_model(domain string,model string)!{
	mut keys:=db.redis.hkeys("actiondbkeys.${domain}.${model}")!
	for key in keys{
		db.redis.hdel("actiondbkeys.${domain}.${model}",key)!
	}
}

//delete al keys for a certain domain
pub fn (mut db DB) delete_domain(domain string)!{
	keys:=db.redis.hkeys("actiondb.${domain}")!
	for key in keys{
		db.redis.hdel("actiondb.${domain}",key)!
	}
	db.keys_delete_domain(domain)!
}
pub fn (mut db DB) delete_model(domain string,model string)!{
	keys:=db.redis.hkeys("actiondb.${domain}.${model}")!
	for key in keys{
		db.redis.hdel("actiondb.${domain}.${model}",key)!
	}
	db.keys_delete_model(domain,model)!
}