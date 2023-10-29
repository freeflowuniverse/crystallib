module main

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.algo.encoder

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

pub fn (o MyStruct) dumpb() ![]u8 {
	mut e := encoder.new() // this already adds a version = 1 to the encoded data

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

pub fn (mut o MyStruct) loadb(data []u8) ! {
	mut d := encoder.decoder_new(data) // this already reads the first byte and ensures version == 1
	// assert d.get_() == 1 // for now just fail if not right version
	cid_int := int(d.get_u32())
	oid_int := int(d.get_u32())
	o.gid = smartid.gid(cid_int: cid_int, oid_int: oid_int)!
	o.name = d.get_string()
	o.nr = d.get_int()
	o.color = d.get_string()
	o.description = d.get_string()
	o.nr2 = d.get_int()
	o.listu32 = d.get_list_u32()
}

fn do() ! {
	cid := smartid.cid(name: 'dbtest')!
	db.new(cid: cid)!

	// cid smartid.CID
	// objtype string //unique type name for obj class
	// index_int []string
	// index_string []string
	db.create(
		cid: cid
		objtype: 'smartcookie'
		index_int: ['a', 'b']
		index_string: [
			'c',
			'd',
		]
	)!

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

	read_o_dump := db.read(o.gid)!
	mut read_o := MyStruct{}
	read_o.loadb(read_o_dump)!
	println('read struct: ${read_o}')
	// TODO: check the data write
	// TODO: check performance, do a perf test for 100k objects
	// TODO: implement the get object code
}

fn main() {
	do() or { panic(err) }
}
