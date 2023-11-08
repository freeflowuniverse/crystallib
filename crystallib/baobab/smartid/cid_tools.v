module smartid

import freeflowuniverse.crystallib.core.texttools
import json
import os


__global (
	ciddb  shared  []CIDDB
)

pub struct CIDDB{
pub mut:
	cid2u32 map[string]u32
}


fn cid_from_name(name string) !CID {
	name2:=texttools.name_fix(name)
	println(1)
	mut cdb:=cid_db_get()!
	println(2)
	if name2 in cdb.cid2u32{
		cidid:=cdb.cid2u32[name2] or {u32(0)}
		return CID{circle:cidid}
	}
	mut highest:=1
	for _,val in cdb.cid2u32{
		if val > highest{
			highest=val
		}
	}
	cdb.cid2u32[name2]=u32(highest+1)
	println(3)
	cid_db_set(cdb)!
	return CID{circle:cdb.cid2u32[name2]}
}

fn name_from_u32(id u32) !string {
	mut cdb:=cid_db_get()!
	for key,val in cdb.cid2u32{
		if val==id{
			return key
		}
	}
	return error("Didn't find cid with id:'$id'")
}


//the core functions with lock 

fn cid_db_get() !CIDDB {
	lock ciddb{
		if ciddb.len==0{
			ciddb<< CIDDB{}
		}
		println(ciddb[0].cid2u32)
		if ciddb[0].cid2u32.keys().len==0{
			println(":check disk")
			if os.exists("${dbpath()}//ciddb.json"){
				d:=os.read_file("${dbpath()}//ciddb.json")!
				cdb:=json.decode(CIDDB,d)!
				ciddb[0]=cdb
				println(":decode")
			}else{
				ciddb[0].cid2u32["core"]=1
				println(":exists")
			}
		}
		return ciddb[0]
	}
	panic("bug")
}

fn dbpath() string{
	mut h:=os.getenv("HOME")
	if h==""{
		panic("can't find home env")
	}
	return "${h}/hero/db"
}

fn cid_db_set(cdb CIDDB) !{
	mut d:=""
	lock ciddb{
		if ciddb.len==0{
			ciddb<< cdb
		}				
		d=json.encode(ciddb[0])
	}
	println("write1")
	os.mkdir_all(dbpath())!
	os.write_file("${dbpath()}/ciddb.json",d)!
	println("write2")
}
