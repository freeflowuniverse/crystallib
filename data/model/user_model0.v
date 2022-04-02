module model
import crypto.md5
import os
import json
import sqlite


///////////FACTORY FUNCTIONALITY


//initialize a table
fn (mut df DataFactory) table_user_init(reset bool) ? {

	path0 := df.path_data+"/user"
	if ! os.exists(path0){
		os.mkdir_all(path0)?
	}

	dbpath0 := path0+"/index.db"

	if reset{
		os.rm(dbpath0)?
	}

	mut table := TableUser{
		path_data : path0
		factory : &df
		db_index : db
	}	

	if ! os.exists(dbpath0){
		//TODO: how to create indexes
		mut db := sqlite.connect(dbpath0) ?
		sql db {
			create table IndexUser
			create table IndexUserTags
		}	

		table.sql_exec( 'CREATE INDEX user_id ON user (obj_id);')?
		table.sql_exec( 'CREATE INDEX user_tags_id ON user_tags (obj_id);')?
		table.sql_exec( 'CREATE INDEX user_name ON user (name);')?
		table.sql_exec( 'CREATE INDEX user_tags_name ON user_tags (tag);')?

		db.close()?
	}


	df.user = &table

	//to be overruled by the developer, default is empty
	df.user.init()?


}

///////////TABLE FUNCTIONALITY

//there is a table per object type, holds path to sqlite and also the map to the data as cache
pub struct TableUser {
pub mut:
	cache		map[int]&User
	path_data	string
	factory		&DataFactory		[skip]
	db_index 	sqlite.DB 			[skip]
	//this allows us to give the right id to an object
	id_last		int
}

[table: 'user']
struct IndexUser {
	id        int    [primary; sql: serial]
	obj_id    int   
	name      string
	description string
}

[table: 'user_tags']
struct IndexUserTags {
	id        int    [primary; sql: serial]
	obj_id        int    
	tag      string 
}


//return object
pub fn (mut table TableUser)  new() ?&User {
	mut obj := User{
			id:table.id_last
			db_index: table.db_index
		}
	table.cache[table.id_last] = &obj	
	table.id_last+=1
	return table.cache[table.id_last]
}

//get, if not found will give error
pub fn (mut table TableUser) get(args0 ArgModelGet) ?&User {
	mut args := args0
	if args.name.len > 0 {
		args.id = 0
		args.name = ""
	}	
	if args.id > 0 {
		if args.id in table.cache{
			return table.cache[args.id]
		}
		path1 :=  df.path_data+"/user"+"/"+args.id.str()+".json"
		if os.exists(path1){
			data := os.read_file(path1)?
			obj := json.decode(User,data)?
			table.cache[args.id] = &obj	
			return table.cache[args.id]		
		}
	}
	return error("cannot find user "+args.id.str()+" "+args.name.str())
}

//check the data obj exists
pub fn (mut table TableUser) exists(args ArgModelGet) bool {
	table.cache.get(args) or {
		return false
	}
	return true
}



fn  (mut table TableUser) sql_exec(sql string) ? {
		rc := table.db_index.exec_none(sql)
		if rc != 101 {return error("Could not execute query:\n"+sql)}
}	



pub fn (mut df DataFactory) user_index_load() ? {

}



////////////////FUNCTIONS ON OBJECT

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
		obj.index_()? //index the object
	}
	obj.changed = false
	return changed
}

fn (mut obj User) index_() ? {

	//first we need to do the default indexing operations
	index_obj1 := IndexUser{
		obj_id: obj.id
		name: obj.name
		description: obj.description
	}
	sql obj.db {
		insert var into Foo
	}

	obj.index_add()?	
	
}

