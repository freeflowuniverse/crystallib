module main

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.algo.encoder
import time

struct MyStruct {
pub mut:
	gid         smartid.GID
	name        string
	nr          int
	color       string
	description string
	nr2         int
	listu32     []u32
}

pub fn (o MyStruct) set() ! {
	// the next will create the table if it doesn't exist yet, only checks once per mem session
	db.create(
		cid: o.gid.cid
		objtype: 'mystruct'
		index_int: ['nr', 'nr2']
		index_string: [
			'name',
			'color',
		]
	)!

	// get the serialization (is a quite efficient small serialization protocol)
	data := o.dumpb()!
	mut index_int := map[string]int{}
	index_int['nr'] = o.nr
	index_int['nr2'] = o.nr2
	mut index_string := map[string]string{}
	index_string['name'] = o.name
	index_string['color'] = o.color
	// pass the data to the database
	db.set(
		gid: o.gid
		objtype: 'mystruct'
		index_int: index_int
		index_string: index_string
		data: data
	)!
}

pub fn get(gid smartid.GID) !MyStruct {
	data := db.read(gid)!
	return loadb(data)!
}

pub fn find(args db.DBQueryArgs) ![]MyStruct {
	data := db.find(args)!
	mut read_o := []MyStruct{}
	for d in data {
		read_o << loadb(d)!
	}

	return read_o
}

[params]
pub struct DumpArgs {
pub mut:
	json bool
}

// this is the method to dump binary form
pub fn (o MyStruct) dumpb(args DumpArgs) ![]u8 {
	mut e := encoder.new()
	e.add_u32(o.gid.cid.u32())
	e.add_u32(o.gid.oid())
	e.add_string(o.name)
	e.add_int(o.nr)
	e.add_string(o.color)
	e.add_string(o.description)
	e.add_int(o.nr2)
	e.add_list_u32(o.listu32)

	return e.data
}

// this is the method to load binary form
pub fn loadb(data []u8) !MyStruct {
	mut o := MyStruct{}
	mut d := encoder.decoder_new(data) // this already reads the first byte and ensures version == 1
	cid_int := int(d.get_u32())
	oid_int := int(d.get_u32())
	o.gid = smartid.gid(cid_int: cid_int, oid_int: oid_int)!
	o.name = d.get_string()
	o.nr = d.get_int()
	o.color = d.get_string()
	o.description = d.get_string()
	o.nr2 = d.get_int()
	o.listu32 = d.get_list_u32()

	return o
}

fn do() ! {
	cid := smartid.cid(name: 'dbtest')!
	db.new(cid: cid)!

	mut o := MyStruct{
		gid: cid.gid()!
		name: 'my name'
		nr: 2
		color: 'red'
		description: 'is this a serious descripion'
		nr2: 10
		listu32: [u32(2), u32(3), u32(4)]
	}
	o.set()!

	mut o2 := MyStruct{
		gid: cid.gid()!
		name: 'my second name'
		nr: 2
		color: 'blue'
		nr2: 11
		listu32: [u32(5), u32(6), u32(7)]
	}
	o2.set()!

	read_o_dump := db.read(o.gid)!

	read_o := loadb(read_o_dump)!
	println('read result: ${read_o}')

	find_result := find(
		cid: cid
		objtype: 'mystruct'
		query_int: {
			'nr': 2
		}
	)!
	println('find result: ${find_result}')

	db.delete(gid: o.gid, objtype: 'mystruct')!
	db.delete(gid: o2.gid, objtype: 'mystruct')!

	perf_write(cid)!
	perf_find(cid)!
	perf_delete(cid)!
}

fn perf_write(cid smartid.CID) ! {
	now := time.now()
	for i in 0 .. 1000 {
		o := MyStruct{
			gid: cid.gid()!
			name: 'my ${i} record'
			nr: 1
			color: 'blue'
			nr2: 2
			listu32: [u32(5), u32(6), u32(7)]
		}
		o.set()!
	}
	diff := time.since(now)
	println('writing 1000 objects took ${diff.seconds()} seconds.\n')
}

fn perf_find(cid smartid.CID) ! {
	now := time.now()
	find(
		cid: cid
		objtype: 'mystruct'
		query_int: {
			'nr': 1
		}
	)!
	diff := time.since(now)
	println('querying 1000 objects took ${diff.seconds()} seconds.\n')
}

fn perf_delete(cid smartid.CID) ! {
	find_res := find(
		cid: cid
		objtype: 'mystruct'
		query_int: {
			'nr': 1
		}
	)!

	now := time.now()
	for obj in find_res {
		db.delete(gid: obj.gid, objtype: 'mystruct')!
	}
	diff := time.since(now)
	println('deleting 1000 objects took ${diff.seconds()} seconds.\n')
}

fn main() {
	do() or { panic(err) }
}
