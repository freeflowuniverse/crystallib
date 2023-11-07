module dbreflection

import mystruct {MyStruct}
import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.data.paramsparser

import json
import time

pub struct MyDB {
	db.DB
}

[params]
pub struct DBArgs {
pub mut:
	circlename string
}

pub fn db_new(args DBArgs) !MyDB {
	mut mydb := MyDB{
		circlename: args.circlename
		objtype: 'mystruct'
	}
	mydb.init()!
	return mydb
}

[params]
pub struct NewArgs[T] {
pub mut:
	params             string
	name               string
	description        string
	mtime              string// modification time
	ctime              string // creation time
	object T
}

pub fn (mydb MyDB) new[T](args NewArgs[T]) !T {
	base:=mydb.new_base(
		params:args.params
		name:args.name
		description:args.description
		mtime:args.mtime
		ctime:args.ctime
	)!
	mut o:=args.object{}
	o.Base = base
	return o
}

pub fn (mydb MyDB) set[T](object T) ! {
	data := mydb.serialize[T](object)!
	
	mut index_int := map[string]int
	mut index_string := map[string]string
	$for field in T.fields {
		if field.attrs.contains('index') {
			$if field.typ is int {
				index_int[field.name] = object.$(field.name)
			}
			$if field.typ is string {
				index_string[field.name] = object.$(field.name)
			}
		}
	}

	mydb.set_data(
		gid: object.gid
		index_int: index_int
		index_string: index_string
		data: data
		baseobj: object.Base
	)!
}

pub fn (mydb MyDB) get[T](gid smartid.GID) !T {
	data := mydb.get_data(gid)!
	return mydb.unserialize[T](data)
}

[params]
pub struct FindArgs[T] {
	db.BaseFindArgs
pub mut:
	object T
	mtime_from ?ourtime.OurTime
	mtime_to   ?ourtime.OurTime
	ctime_from ?ourtime.OurTime
	ctime_to   ?ourtime.OurTime
}

//find on our database
//```js
// name  string
// color string
// nr    int
// nr2   int

// name       string
//```
pub fn (mydb MyDB) find[T](args FindArgs[T]) ![]T {	
	mut query_int := map[string]int
	mut query_string := map[string]string

	$for field in T.fields {
		if field.attrs.contains('index') {
			$if field.typ is int {
				query_int[field.name] = args.object.$(field.name)
			}
			$if field.typ is string {
				query_string[field.name] = args.object.$(field.name)
			}
		}
	}
	
	dbfindoargs:=db.DBFindArgs{
		query_int: query_int
		query_string: query_string
	}

	data := mydb.find_base(args.BaseFindArgs,dbfindoargs)!
	mut read_o := []T{}
	for d in data {
		read_o << mydb.unserialize[T](d)!
	}
	return read_o
}

//////////////////////serialization

// this is the method to dump binary form
pub fn (mydb MyDB) serialize[T](obj T) ![]u8 {
	mut enc := encoder.Encoder{}
	$for field in T.fields {
		$if field.typ is db.Base {
			enc = obj.$(field.name).bin_encoder()!
		}
	}

	$for field in T.fields {
		$if field.typ is int {
			enc.add_int(obj.$(field.name))
		}
		$if field.typ is string {
			enc.add_string(obj.$(field.name))
		}
		$if field.typ is []u32 {
			enc.add_list_u32(obj.$(field.name))
		}
	}
	return enc.data
}

// serialize to 3script
pub fn (mydb MyDB) serialize_kwargs[T](obj T) ! map[string]string {
	mut kwargs := obj.Base.serialize_kwargs()!
	
	$for field in T.fields {
		$if field.typ is int {
			val_int := obj.$(field.name)
			kwargs[field.name]="${val_int}"
		}
		$if field.typ is string {
			kwargs[field.name]=obj.$(field.name)
		}
		$if field.typ is []u32 {
			mut listu32:=""
			for i in obj.$(field.name){
				listu32+="${i},"
			}
			listu32=listu32.trim_string_right(",")
			kwargs["listu32"]=listu32
		}
	}
	return kwargs
}


// this is the method to load binary form
pub fn (mydb MyDB) unserialize[T](data []u8) !T {
	// mut d := encoder.decoder_new(data)
	
	mut dec, base := db.base_decoder(data)!
	mut obj := T{
		Base: base
	}
	$for field in T.fields {
		$if field.typ is db.Base {
			// base already decoded above
		}
		$if field.typ is int {
			obj.$(field.name) = dec.get_int()
		}
		$if field.typ is string {
			obj.$(field.name) = dec.get_string()
		}
		$if field.typ is []u32 {
			obj.$(field.name) = dec.get_list_u32()
		}
	}
	return obj
}


// serialize to 3script
pub fn (mydb MyDB) serialize_3script[T](obj T) !string {
	p:=paramsparser.new_from_dict(mydb.serialize_kwargs[T](obj)!)!
	return p.export(pre:"!!${mydb.objtype}.define ")
}


pub fn (mydb MyDB) unserialize_3script[T](txt string) ![]T {
	mut res:=[]T{}
	for r in mydb.base_decoder_3script(txt)!{
		mut o := T{Base: r.base}
		p:=r.params

		$for field in T.fields {
			$if field.typ is db.Base {
				// base already decoded above
			}
			$if field.typ is int {
				obj.$(field.name) = p.get_int_default(field.name,0)!
			}
			$if field.typ is string {
				obj.$(field.name) = p.get_default(field.name,"")!
			}
			$if field.typ is []u32 {
				obj.$(field.name) = dec.get_list_u32(field.name)!
			}
		}
		res<<o
	}
	return res
}
