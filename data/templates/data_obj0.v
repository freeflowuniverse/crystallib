module model
import crypto.md5
import os
import json
import sqlite


[table: '$name']
struct Index${name.capitalize()} {
	id        int    [primary; sql: serial]
	name      string
	description string
	tags string
}

[table: '${name}_tags']
struct Index${name.capitalize()}Tags {
	i_        int    [primary; sql: serial]
	id        int    
	tag      string
}

pub fn (mut df DataFactory) ${name}_new() ?&${name.capitalize()} {
	id2 := 1
	mut obj := ${name.capitalize()}{id:id2}
	@{"df."}${name}s[id2] = &obj	
	return @{"df."}${name}s[id2]
}

//get, if not found will give error
pub fn (mut df DataFactory) ${name}_get(args0 ArgModelGet) ?&${name.capitalize()} {
	mut args := args0
	if args.name.len > 0 {
		args.id = 0
		args.name = ""
	}	
	if args.id > 0 {
		if args.id in @{"df."}${name}s{
			return @{"df."}${name}s[args.id]
		}
		path1 :=  df.path_data+"/${name}"+"/"+args.id.str()+".json"
		if os.exists(path1){
			data := os.read_file(path1)?
			obj := json.decode(${name.capitalize()},data)?
			@{"df."}${name}s[args.id] = &obj	
			return @{"df."}${name}s[args.id]		
		}
	}
	return error("cannot find @name "+args.id.str()+" "+args.name.str())
}

//check the data obj exists
pub fn (mut df DataFactory) ${name}_exists(args ArgModelGet) bool {
	@{"df."}${name}_get(args) or {
		return false
	}
	return true
}

//check if content changed
pub fn (mut obj ${name.capitalize()}) changed() bool {
	key := md5.hexhash(obj.content4hash())
	if key != obj.contentkey{
		obj.changed = true
		obj.contentkey = key
	}
	return obj.changed
}

//save (if it changed will return true, in other words it had to save)
pub fn (mut obj ${name.capitalize()}) save() ?bool {
	mut changed := obj.changed()	
	mut df := factory()
	if changed {
		data := json.encode_pretty(obj)
		path1 :=  df.path_data+"/${name}"+"/"+obj.id.str()+".json"
		os.write_file(path1,data)?
	}
	obj.changed = false
	return changed
}



pub fn (mut df DataFactory) ${name}_init_() ? {

	path0 := df.path_data+"/${name}"
	if ! os.exists(path0){
		os.mkdir_all(path0)?
	}

	dbpath0 := path0+"/index.db"

	if ! os.exists(dbpath0){
		mut db := sqlite.connect(dbpath0) ?
		sql db {
			create table Index${name.capitalize()}
			create table Index${name.capitalize()}Tags
		}	
		db.close()?
	}

	@{"df."}${name}_init()?


}

pub fn (mut df DataFactory) ${name}_index_load() ? {

}