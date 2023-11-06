module main

import mystruct {MyStruct}
import dbreflection
import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.data.ourtime
import time

fn do() ! {
	mydb := dbreflection.db_new(circlename: 'testcircle')!
	println(mydb)

	mydb.delete_all()!

	objs_start := mydb.find[MyStruct](dbreflection.FindArgs[MyStruct]{})!
	assert objs_start.len == 0

	mut o1 := MyStruct{
		gid: mydb.cid.gid()!
		name: 'my name'
		nr: 2
		color: 'red'
		description: 'is this a serious descripion'
		nr2: 10
		listu32: [u32(2), u32(3), u32(4)]
	}
	mydb.set[MyStruct](o1)!

	objs_4 := mydb.find[MyStruct](dbreflection.FindArgs[MyStruct]{})!
	assert objs_4.len == 1

	mut o2 := mydb.new[MyStruct](
		object: MyStruct {
			name: 'my second name'
			nr: 2
			color: 'blue'
			nr2: 11
			listu32: [u32(5), u32(6), u32(7)]
		}
		
	)!
	mydb.set(o2)!

	objs_5 := mydb.find[MyStruct](dbreflection.FindArgs[MyStruct]{})!
	assert objs_5.len == 2

	o3 := mydb.get[MyStruct](o1.gid)!
	println(o1)
	println(o3)
	o1data := mydb.serialize(o1)!
	o3data := mydb.serialize(o3)!
	assert o1data == o3data

	script3:=mydb.serialize_3script(o1)!
	println(script3)

	// objs := mydb.find(
	// 	nr: 1
	// )!
	// objs2 := mydb.find(
	// 	nr: 2
	// 	mtime_from: ourtime.now()
	// )!
	// println(objs2)
	// assert objs.len == 0
	// assert objs2.len == 2

	// mydb.delete(o1.gid)!
	// mydb.delete(o2.gid)!

	// objs_6 := mydb.find()!
	// assert objs_6.len == 0

	perf_write(mydb)!
	perf_find(mydb)!

	mydb.delete_all()!
}


fn perf_write(mydb dbreflection.MyDB) ! {
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

fn perf_find(mydb dbreflection.MyDB) ! {
	now := time.now()
	mydb.find[MyStruct](object: MyStruct{nr: 1})!
	diff := time.since(now)
	println('querying 1000 objects took ${diff.seconds()} seconds.\n')
}

fn main() {
	do() or { panic(err) }
}
