module model
import crypto.md5
import os
import json
import sqlite


@{model.comments_str()}
pub struct @{model.name}Serialized {
pub mut:
@for mut field in model.fields
	@field.name @{field.typestr_primitive()}
@end
}



///////////FACTORY FUNCTIONALITY


//initialize a table
fn (mut df DataFactory) table_${name}_init(reset bool) ? {

	path0 := df.path_data+"/${name}"
	if ! os.exists(path0){
		os.mkdir_all(path0)?
	}

	dbpath0 := path0+"/index.db"

	if reset{
		os.rm(dbpath0)?
	}


	if ! os.exists(dbpath0){
		//TODO: how to create indexes
		mut db := sqlite.connect(dbpath0) ?
		sql db {
			create table Index${name.capitalize()}
			create table Index${name.capitalize()}Tags
		}	

		table.sql_exec( 'CREATE INDEX ${name}_id ON ${name} (obj_id);')?
		table.sql_exec( 'CREATE INDEX ${name}_tags_id ON ${name}_tags (obj_id);')?
		table.sql_exec( 'CREATE INDEX ${name}_name ON ${name} (name);')?
		table.sql_exec( 'CREATE INDEX ${name}_tags_name ON ${name}_tags (tag);')?

		db.close()?
	}


	@{"df."}${name} = &table

	//to be overruled by the developer, default is empty
	@{"df."}${name}.init()?


}

///////////TABLE FUNCTIONALITY

//there is a table per object type, holds path to sqlite and also the map to the data as cache
[heap]
pub struct Table${name.capitalize()} {
pub mut:
	cache		map[int]${name.capitalize()}
	path_data	string
	db_index 	sqlite.DB 			[skip]
	//this allows us to give the right id to an object
	id_last		int
}


[table: '$name']
struct Index${name.capitalize()} {
	id        int    [primary; sql: serial]
	obj_id    int   
	name      string
	description string
}

[table: '${name}_tags']
struct Index${name.capitalize()}Tags {
	id        int    [primary; sql: serial]
	obj_id        int    
	tag      string 
}


//return object
pub fn (mut table Table${name.capitalize()})  new() ?&${name.capitalize()} {
	mut obj := ${name.capitalize()}{
			id:table.id_last
			db_index: table.db_index
		}
	@{"table."}cache[table.id_last] = &obj	
	table.id_last+=1
	return @{"table."}cache[table.id_last]
}

//get, if not found will give error
pub fn (mut table Table${name.capitalize()}) get(args0 ArgModelGet) ?&${name.capitalize()} {
	mut args := args0
	if args.name.len > 0 {
		args.id = 0
		args.name = ""
	}	
	if args.id > 0 {
		if args.id in @{"table."}cache{
			return @{"table."}cache[args.id]
		}
		path1 :=  df.path_data+"/${name}"+"/"+args.id.str()+".json"
		if os.exists(path1){
			data := os.read_file(path1)?
			obj := json.decode(${name.capitalize()},data)?
			@{"table."}cache[args.id] = &obj	
			return @{"table."}cache[args.id]		
		}
	}
	return error("cannot find @name "+args.id.str()+" "+args.name.str())
}

//check the data obj exists
pub fn (mut table Table${name.capitalize()}) exists(args ArgModelGet) bool {
	@{"table."}cache.get(args) or {
		return false
	}
	return true
}



fn  (mut table Table${name.capitalize()}) sql_exec(sql string) ? {
		rc := @{"table."}db_index.exec_none(sql)
		if rc != 101 {return error("Could not execute query:\n"+sql)}
}	



pub fn (mut df DataFactory) ${name}_index_load() ? {

}



////////////////FUNCTIONS ON OBJECT

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
		obj.index_()? //index the object
	}
	obj.changed = false
	return changed
}

fn (mut obj ${name.capitalize()}) index_() ? {

	//first we need to do the default indexing operations
	index_obj1 := Index${name.capitalize()}{
		obj_id: obj.id
		name: obj.name
		description: obj.description
	}
	sql obj.db {
		insert var into Foo
	}

	obj.index_add()?	
	
}

