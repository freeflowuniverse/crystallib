module db

import json
// import freeflowuniverse.crystallib.data.paramsparser
// import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.ourtime


[params]
pub struct DBSetArgs {
pub mut:
	gid          smartid.GID
	objtype      string // unique type name for obj class
	index_int    map[string]int
	index_string map[string]string
	data         []u8 //if empty will do json
	baseobj		 Base
	json bool //we can set as json or as binary data

}

pub fn  (db DB) set_data(args_ DBSetArgs)  ! {
	//create the table if it doesn't exist yet
	mut args:=args_

	args.index_int["mtime"]=args.baseobj.mtime.int()
	args.index_int["ctime"]=args.baseobj.ctime.int()
	args.index_string["name"]=args.baseobj.name

	mut index_int:= args.index_int.keys()
	mut index_string:= args.index_string.keys()
	create(
		cid: db.cid
		objtype: "base_${db.objtype}"
		index_int: args.index_int.keys()
		index_string: args.index_string.keys()
	)!
	set(
		gid: args.gid
		objtype: db.objtype
		index_int: args.index_int
		index_string: args.index_string
		data: args.data
	)!
}

pub fn  (db DB) get_date(gid smartid.GID) ![]u8 {
	data := get(gid:gid,objtype: db.objtype)!
	return data
}

pub fn  (db DB)  delete(gid smartid.GID) ! {
	delete(cid:db.cid,gid:gid,objtype:db.objtype)!
}

pub fn  (db DB)  delete_all() ! {
	delete(cid:db.cid,objtype:db.objtype)!
}


[params]
pub struct BaseFindArgs {
pub mut:
	mtime_from ourtime.OurTime
	mtime_to ourtime.OurTime
	ctime_from ourtime.OurTime
	ctime_to ourtime.OurTime
	name string
}


pub fn (db DB) basefind(args BaseFindArgs) ![]MyStruct {
	mut query_int:=map[string]int{}
	mut query_args:=DBQueryArgs{
		objtype      : db.objtype
		query_int    : query_int
		query_string : query_str
	}
	//TODO: need to implement this
	// println(query_args)
	data := db.find(query_args)!
	mut read_o := []MyStruct{}
	for d in data {
		read_o << mydb.unserialize(d)!
	}
	return read_o
}

//////////////////////serialization

// this is the method to dump binary form
pub fn (db DB) serialize(o MyStruct)![]u8 {
		
	mut e:=o.bin_encoder()!
	e.add_int(o.nr)
	e.add_string(o.color)
	e.add_int(o.nr2)
	e.add_list_u32(o.listu32)

	// if mydb.version==1{
	// }else if mydb.version==2{
	// 	panic("not implemented")
	// 	//json
	// 	// data:=json.encode(o)
	// 	// e.add_u8(2)//this is version 1, for binary
	// 	// e.add_string(data)
	// }else if mydb.version==3{
	// 	// e.add_u8(3)//this is version 1, for binary
	// 	//3script
	// 	panic("not implemented")
	// }else{
	// 	panic("not implemented")
	// }
	return e.data
}

// this is the method to load binary form
pub fn (db DB) unserialize(data []u8) !MyStruct {
	// mut d := encoder.decoder_new(data) 
	mut d,base:=system.base_decoder(data)!
	mut o:=MyStruct{Base:base}
	o.nr = d.get_int()
	o.color = d.get_string()
	o.nr2 = d.get_int()
	o.listu32 = d.get_list_u32()

	// if v==1{
	// }else if v==2{
	// 	panic("not implemented")
	// 	//json
	// 	// data2:=d.get_string()
	// 	// o=json.decode(MyStruct,data2) or {MyStruct{}}
	// }else if v==3{
	// 	//3script
	// 	panic("not implemented")
	// }else{
	// 	panic("not implemented")
	// }
	return o
}