module mystruct

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.paramsparser

import json
import time

pub struct MyDB {
	db.DB
}

pub struct MyStruct {
	db.Base
pub mut:
	nr      int
	color   string
	nr2     int
	listu32 []u32
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

pub fn (mydb MyDB) set(o MyStruct) ! {
	data := mydb.serialize(o)!
	mydb.set_data(
		gid: o.gid
		index_int: {
			'nr':  o.nr
			'nr2': o.nr2
		}
		index_string: {
			'name':  o.name
			'color': o.color
		}
		data: data
		baseobj: o.Base
	)!
}

pub fn (mydb MyDB) get(gid smartid.GID) !MyStruct {
	data := mydb.get_data(gid)!
	return mydb.unserialize(data)
}

[params]
pub struct FindArgs {
	db.BaseFindArgs
pub mut:
	name  string
	color string
	nr    int
	nr2   int
}

//find on our database
//```js
// name  string
// color string
// nr    int
// nr2   int
// mtime_from ?ourtime.OurTime
// mtime_to   ?ourtime.OurTime
// ctime_from ?ourtime.OurTime
// ctime_to   ?ourtime.OurTime
// name       string
//```
pub fn (mydb MyDB) find(args FindArgs) ![]MyStruct {	
	mut query_int := map[string]int{}
	data := db.find(
		args.BaseFindArgs,{
			query_int: {
				'nr':  args.nr
				'nr2': args.nr2
			}
			query_string: {
				'name':  args.name
				'color': args.color
			}			
		}
	)!
	mut read_o := []MyStruct{}
	for d in data {
		read_o << mydb.unserialize(d)!
	}
	return read_o
}

//////////////////////serialization

// this is the method to dump binary form
pub fn (mydb MyDB) serialize(o MyStruct) ![]u8 {
	mut e := o.bin_encoder()!
	e.add_int(o.nr)
	e.add_string(o.color)
	e.add_int(o.nr2)
	e.add_list_u32(o.listu32)
	return e.data
}

// serialize to 3script
pub fn (mydb MyDB) serialize_kwargs(o MyStruct) map[string]string {
	mut kwargs := o.Base.serialize_kwargs()
	kwargs["nr"]="${o.nr}"
	kwargs["nr2"]="${o.nr2}"
	kwargs["color"]=o.color
	mut listu32:=""
	for i in listu32{
		listu32+="${i},"
	}
	listu32=listu32.trim_string_right(",")
	kwargs["listu32"]=listu32
	return kwargs
}


// this is the method to load binary form
pub fn (mydb MyDB) unserialize(data []u8) !MyStruct {
	// mut d := encoder.decoder_new(data)
	mut d, base := db.base_decoder(data)!
	mut o := MyStruct{
		Base: base
	}
	o.nr = d.get_int()
	o.color = d.get_string()
	o.nr2 = d.get_int()
	o.listu32 = d.get_list_u32()
	return o
}


// serialize to 3script
pub fn (mydb MyDB) serialize_3script(o MyStruct) !string {
	p:=paramsparser.new_from_dict(mydb.serialize_kwargs(o))!
	return p.export(pre:"!!${mydb.objtype}.define ")
}


pub fn (mydb MyDB) unserialize_3script(txt string) ![]MyStruct {
	mut res:=[]MyStruct{}
	for r in mydb.base_decoder_3script(txt)!{
		mut o := MyStruct{Base: r.base}
		p:=r.params
		o.nr = p.get_int_default("nr",0)!
		o.color = p.get_default("color","")!
		o.nr2 = p.get_int_default("nr",0)!
		o.listu32 = p.get_list_u32("listu32")!
		res<<o
	}
	return res
}
