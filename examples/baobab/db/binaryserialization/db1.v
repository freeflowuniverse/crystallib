module main

import mystruct
import time

fn do() ! {
	mydb := mystruct.db_new(circlename: 'testcircle')!
	println(mydb)

	mydb.delete_all()!

	mydb.find() or { println('this should fail, tables are still not created. ${err}') }

	// params             string
	// name               string
	// description        string
	// mtime              string// modification time
	// ctime              string // creation time
	// nr      int
	// color   string
	// nr2     int
	// listu32 []u32

	mut o1 := mydb.new(
		name: 'my name'
		nr: 2
		color: 'red'
		description: 'is this a serious descripion'
		nr2: 10
		listu32: [u32(2), u32(3), u32(4)]
	)!
	mydb.set(o1)!

	objs_4 := mydb.find()!
	assert objs_4.len == 1

	mut o2 := mydb.new(
		name: 'my second name'
		nr: 2
		color: 'blue'
		nr2: 11
		listu32: [u32(5), u32(6), u32(7)]
	)!
	mydb.set(o2)!

	objs_5 := mydb.find()!
	assert objs_5.len == 2

	o3 := mydb.get(o1.gid)!
	println(o1)
	println(o3)
	o1data := mydb.serialize(o1)!
	o3data := mydb.serialize(o3)!
	assert o1data == o3data

	script3 := mydb.serialize_3script(o1)!
	deserialized_3script := mydb.unserialize_3script(script3)!

	deserialized_o := deserialized_3script[0]
	assert deserialized_o.gid == o1.gid
	assert deserialized_o.params == o1.params
	assert deserialized_o.version_base == o1.version_base
	assert deserialized_o.serialization_type == o1.serialization_type
	assert deserialized_o.name == o1.name
	assert deserialized_o.description == o1.description
	assert deserialized_o.remarks == o1.remarks
	assert deserialized_o.mtime.str() == o1.mtime.str()
	assert deserialized_o.ctime.str() == o1.ctime.str()
	assert deserialized_o.nr == o1.nr
	assert deserialized_o.color == o1.color
	assert deserialized_o.nr2 == o1.nr2
	assert deserialized_o.listu32 == o1.listu32

	objs := mydb.find(
		nr: 1
	)!
	objs2 := mydb.find(
		nr: 2
		// mtime_from: ourtime.new("-1h") //TODO, doesn't work
	)!
	println(objs2)
	assert objs.len == 0
	assert objs2.len == 2

	mydb.delete(o1.gid)!
	mydb.delete(o2.gid)!

	objs_6 := mydb.find()!
	assert objs_6.len == 0

	perf_write(mydb)!
	perf_find(mydb)!

	mydb.delete_all()!
}

fn perf_write(mydb mystruct.MyDB) ! {
	now := time.now()
	for i in 0 .. 1000 {
		o := mystruct.MyStruct{
			gid: mydb.cid.gid()!
			name: 'my ${i} record'
			nr: 1
			color: 'blue'
			nr2: 2
			listu32: [u32(5), u32(6), u32(7)]
		}
		mydb.set(o)!
	}
	diff := time.since(now)
	println('writing 1000 objects took ${diff.seconds()} seconds.\n')
}

fn perf_find(mydb mystruct.MyDB) ! {
	now := time.now()
	objs := mydb.find(nr: 1)!
	diff := time.since(now)
	println('querying 1000 objects took ${diff.seconds()} seconds.\n')
	assert objs.len == 1000
}

fn main() {
	do() or { panic(err) }
}
