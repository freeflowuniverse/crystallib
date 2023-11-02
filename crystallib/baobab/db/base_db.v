module db

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
	data         []u8 // if empty will do json
	baseobj      Base
	json         bool // we can set as json or as binary data
}

pub fn (db DB) set_data(args_ DBSetArgs) ! {
	// create the table if it doesn't exist yet
	mut args := args_

	args.index_int['mtime'] = args.baseobj.mtime.int()
	args.index_int['ctime'] = args.baseobj.ctime.int()
	args.index_string['name'] = args.baseobj.name

	create(
		cid: db.cid
		objtype: 'base_${db.objtype}'
		index_int: args.index_int.keys()
		index_string: args.index_string.keys()
	)!
	set(
		gid: args.gid
		objtype: 'base_${db.objtype}'
		index_int: args.index_int
		index_string: args.index_string
		data: args.data
	)!
}

pub fn (db DB) get_data(gid smartid.GID) ![]u8 {
	data := get(gid: gid, objtype: db.objtype)!
	return data
}

pub fn (db DB) delete(gid smartid.GID) ! {
	delete(cid: db.cid, gid: gid, objtype: db.objtype)!
}

pub fn (db DB) delete_all() ! {
	delete(cid: db.cid, objtype: db.objtype)!
}

[params]
pub struct BaseFindArgs {
pub mut:
	mtime_from ourtime.OurTime
	mtime_to   ourtime.OurTime
	ctime_from ourtime.OurTime
	ctime_to   ourtime.OurTime
	name       string
}

pub fn (db DB) basefind(args DBFindArgs) ![][]u8 {
	return find(args)!
}
