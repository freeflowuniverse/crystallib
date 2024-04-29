module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient	
import os

@[heap]
pub struct DBCollection {
pub mut:
	path   pathlib.Path
	name   string
	secret string
	contextid id
	memberid int //needed to do autoincrement of the DB, when user logged in we need memberid, memberid is unique per circle
	member_pubkeys map[int]string
}

pub fn (mut dbcollection DBCollection) get_encrypted(name_ string) !DB {
	mut db := dbcollection.get(name_)!
	db.encrypt()!
	return db
}

pub fn (mut dbcollection DBCollection) incr() !int {

	mut r := redisclient.core_get()!
	if dbcollection.contextid>0{
		//make sure we are on the right db
		r.selectdb(dbcollection.contextid)!
	}	
	lid:=r.get("context:lastid")!
	if lid==none{
		incr_file:=dbcollection.path.file_get("incr_${memberid}")!
		c:=incr_file.read() or {""}
		if c==""{
			c:=incr_file.write("1")!
			r.set("context:lastid","1")!
			return 1
		}
	}

}




// get a DB from the dbcollection
pub fn (mut dbcollection DBCollection) get(name_ string) !DB {
	name := texttools.name_fix(name_)
	mut p := pathlib.get_dir(create: true, path: '${dbcollection.path.path}/${name}')!
	mut encrypted := false
	if os.exists('${dbcollection.path.path}/${name}/encrypted') {
		encrypted = true
	}
	mut db2 := DB{
		name: name
		path: p
		encrypted: encrypted
		parent: &dbcollection
	}
	if encrypted {
		if dbcollection.secret.len < 4 {
			return error('secret needs to be specified on dbcollection level, now < 4 chars. \nDB: ${dbcollection}')
		}
	}
	return db2
}

pub fn (mut collection DBCollection) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	return os.exists('${collection.path.path}/${name}')
}

pub fn (mut collection DBCollection) delete(name_ string) ! {
	name := texttools.name_fix(name_)
	mut datafile := collection.path.dir_get(name) or { return }
	datafile.delete()!
}

pub fn (mut collection DBCollection) list() ![]string {
	mut r := collection.path.list(recursive: false, dirs_only: true)!
	mut res := []string{}
	for item in r.paths {
		res << item.name()
	}
	return res
}

pub fn (mut collection DBCollection) prefix(prefix string) ![]string {
	mut res := []string{}
	for item in collection.list()! {
		// println(" ---- $item ($prefix)")
		if item.trim_space().starts_with(prefix) {
			// println("888")
			res << item
		}
	}
	return res
}

// delete all data in the dbcollection (be careful)
pub fn (mut collection DBCollection) destroy() ! {
	collection.path.delete()!
}
