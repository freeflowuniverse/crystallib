module smartid

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient

[params]
pub struct CIDGet {
pub mut:
	name string
	id_int u32 
	id_string string
}

// get a cid id based on cidname, id_int or id_string
pub fn cid_get(args CIDGet) !CID {
	if args.id_int>0{
		return CID{circle:args.id_int}
	}else if args.id_string.len>0{
		return CID{circle:sid_int(args.id_string)}
	}else if args.name.len>0{
		cidname := texttools.name_fix(args.name)
		key:='circle:names:${cidname}'
		mut redis := redisclient.core_get()!
		mut cid := redis.get(key)!
		if cid == ""{
			//means we don't have it het
			cid0:=cid_core()
			cid=sid_new(cid0.str())!
			redis.set(key, '${cid}')!
			cid = redis.get(key) or {panic("bug")}
			id2name_key:='circle:id2name:${cid}'
			redis.set(id2name_key, '${cidname}')!
		}		
		return CID{circle:sid_int(cid)}
	}else{
		return error("need to specify name, id_int or id_string")
	}
	panic("bug")
}

//this is the cid for circle0
pub fn cid_core() CID {
	mut cid:=CID{circle:0}
	return cid
}


pub struct CID {
pub mut:
	circle u32
}


pub fn (cid CID) u32() u32{
	return cid.circle
}

pub fn (cid CID) str() string{
	return sid_str(cid.circle)
}

pub fn (cid CID) name() string{
	if cid.circle==0{
		return "core"
	}
	mut redis := redisclient.core_get() or {panic("can't connect to redis")}
	id2name_key:='circle:id2name:${cid}' //is the string representation
	name:=redis.get(id2name_key)or {panic("can't connect to redis")}
	if name==""{
		panic("name should not be empty in redis for $cid")
	}
	return name
}

pub fn (cid CID) gid_get(id string) !GID{
	return gid_get(id:id,cid:cid.str())
}

pub fn (cid CID) gid_new() !GID{
	return gid_get(cid:cid.str())
}

pub fn (cid CID) sids_replace(txt string) !string{
	return sids_replace(cid.str(),txt)!
}

pub fn (cid CID) sids_acknowledge(txt string) !{
	sids_acknowledge(cid.str(),txt)!
}

