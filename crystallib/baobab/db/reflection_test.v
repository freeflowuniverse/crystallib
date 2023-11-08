module db

import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.algo.encoder
import freeflowuniverse.crystallib.data.paramsparser
import json
import os
import time

const(
	circlename = 'testci'
	objtype = 'TestStruct'
)

__global(
	test_db DB
)

struct TestStruct {
	Base
	text string
	number int
	u32s []u32
}

fn testsuite_begin() {
	test_db = DB{
		circlename: circlename
		objtype: objtype
	}
	test_db.init()!
}

fn testsuite_end() {
	delete(
		cid: test_db.cid
		objtype: objtype
	)!
}

fn test_new() {
	object := test_db.new[TestStruct](
		name: 'Tester'
		description: 'A test object created for the sake of testing.'
		object: TestStruct {
			text: 'Test text'
			number: 42
			u32s: [u32(11), u32(101)]
		}
	)!

	// test base and object fields are filled in correctly
	assert smartid.gid_check(object.gid.str())
	assert object.version_base == 1
	assert object.serialization_type == .bin
	assert object.name == 'Tester'
	assert object.number == 42
}

fn test_set() {
	object := test_db.new[TestStruct](
		name: 'Tester'
		description: 'A test object created for the sake of testing.'
		object: TestStruct {
			text: 'Test text'
			number: 42
			u32s: [u32(11), u32(101)]
		}
	)!
	test_db.set[TestStruct](object)!
	
	// test that serialized object exists in db table
	serialized := test_db.serialize[TestStruct](object)!
	assert serialized == table_get(mut test_db, object.gid)!

	// TODO: test that object is written to find table with indeces.
}

fn test_get() {
	object := test_db.new[TestStruct](
		name: 'Tester'
		description: 'A test object created for the sake of testing.'
		object: TestStruct {
			text: 'Test text'
			number: 42
			u32s: [u32(11), u32(101)]
		}
	)!
	test_db.set[TestStruct](object)!
	assert object == test_db.get[TestStruct](object.gid)!
}

fn test_find() {
	object := test_db.new[TestStruct](
		name: 'FindTester'
		description: 'A test object created for the sake of testing.'
		object: TestStruct {
			text: 'Test text'
			number: 42
			u32s: [u32(11), u32(101)]
		}
	)!
	test_db.set[TestStruct](object)!

	assert find_by_name(object)
	assert find_by_mtime(object)
	assert find_by_ctime(object)
}

fn find_by_name(object TestStruct) bool {
	found_objs := test_db.find[TestStruct](
		name: object.name
		object: TestStruct{}
	)!
	return found_objs.len == 1 && found_objs[0] == object
}

fn find_by_mtime(object TestStruct) bool {
	found_objs := test_db.find[TestStruct](
		name: object.name
		object: TestStruct{}
	)!
	return found_objs.len == 1 && found_objs[0] == object
}

fn find_by_ctime(object TestStruct) bool {
	found_objs := test_db.find[TestStruct](
		name: object.name
		object: TestStruct{}
	)!
	return found_objs.len == 1 && found_objs[0] == object
}