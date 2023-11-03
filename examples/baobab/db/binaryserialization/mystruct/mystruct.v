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

// TODO: use enumerator and do differently (despiegk)
[params]
pub struct DBArgs {
pub mut:
	circlename string
	version    u8 = 1 // 1 is bin, 2 is json, 3 is 3script
}

pub fn db_new(args DBArgs) !MyDB {
	mut mydb := MyDB{
		circlename: args.circlename
		version: args.version
		objtype: 'mystruct'
	}
	mydb.init()!
	return mydb
}

pub fn (mydb MyDB) set(o MyStruct) ! {
	data := mydb.serialize(o)!
	mydb.set_data(
		gid: o.gid
		objtype: mystruct.objtype
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

pub fn (mydb MyDB) find(args FindArgs) ![]MyStruct {	
	mut query_int := map[string]int{}
	if args.nr > 0 {
		query_int['nr'] = args.nr
	}
	if args.nr2 > 0 {
		query_int['nr2'] = args.nr
	}

	mut query_str := map[string]string{}
	if args.name.len > 0 {
		query_str['name'] = args.name
	}
	if args.color.len > 0 {
		query_str['color'] = args.color
	}

	mut query_args := db.DBFindArgs{
		cid: mydb.cid
		objtype: mystruct.objtype
		query_int: query_int
		query_string: query_str
	}
	query_args.complete(args.BaseFindArgs) //will add the time and name find args
	println(query_args)
	data := db.find(query_args)!
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
	mut kwargs := o.Base.kwargs()
	kwargs<< {
		"nr":"${o.nr}"
		"nr2":"${o.nr2}"
		"color":o.color
		"listu32":",".join(o.listu32)
	}
	return kwargs
}


// this is the method to load binary form
pub fn (mydb MyDB) unserialize(data []u8) !MyStruct {
	// mut d := encoder.decoder_new(data)
	mut d, base := mydb.base_decoder(data)!
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
		o.nr = p.get_int("nr")
		o.color = d.get_string("color")
		o.nr2 = d.get_int("nr")
		o.listu32 = d.get_list_u32("listu32")
		res<<o
	}
	return res
}
