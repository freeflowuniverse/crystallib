module model
import crypto.md5
import os
import json
import sqlite

[table: 'user_tags']
struct IndexUserTags {
	i_        int    [primary; sql: serial]
	id        int    
	tag      string
}

pub fn (mut df DataFactory) user_new() ?&User {
	id2 := 1
	mut obj := User{id:id2}
	df.users[id2] = &obj	
	return df.users[id2]
}

//get, if not found will give error
pub fn (mut df DataFactory) user_get(args0 ArgModelGet) ?&User {
	mut args := args0
	if args.name.len > 0 {
		args.id = 0
		args.name = ""
	}	
	if args.id > 0 {
		if args.id in df.users{
			return df.users[args.id]
		}
		path1 :=  df.path_data+"/user"+"/"+args.id.str()+".json"
		if os.exists(path1){
			data := os.read_file(path1)?
			obj := json.decode(User,data)?
			df.users[args.id] = &obj	
			return df.users[args.id]		
		}
	}
	return error("cannot find user "+args.id.str()+" "+args.name.str())
}

//check the data obj exists
pub fn (mut df DataFactory) user_exists(args ArgModelGet) bool {
	df.user_get(args) or {
		return false
	}
	return true
}

//check if content changed
pub fn (mut obj User) changed() bool {
	key := md5.hexhash(obj.content4hash())
	if key != obj.contentkey{
		obj.changed = true
		obj.contentkey = key
	}
	return obj.changed
}

//save (if it changed will return true, in other words it had to save)
pub fn (mut obj User) save() ?bool {
	mut changed := obj.changed()	
	mut df := factory()
	if changed {
		data := json.encode_pretty(obj)
		path1 :=  df.path_data+"/user"+"/"+obj.id.str()+".json"
		os.write_file(path1,data)?
	}
	obj.changed = false
	return changed
}



pub fn (mut df DataFactory) user_init() ? {

	path0 := df.path_data+"/user"
	if ! os.exists(path0){
		os.mkdir_all(path0)?
	}

	dbpath0 := path0+"/index.db"

	if ! os.exists(dbpath0){
		mut db := sqlite.connect(dbpath0) ?
		sql db {
			create table IndexUser
			create table IndexUserTags
		}	
		db.close()?
	}
}

pub fn (mut df DataFactory) user_index_load() ? {

}
