module model

import sqlite

// Data object for user
pub struct User {
pub mut:
	id          int
	name        string
	description string
	tags        []string
	remarks     []int
	contentkey  string
	changed     bool     [skip]
	// last used from memory, this to let cache work
	access_last int        [skip]
	table       &TableUser [skip]
}

// produce the content on which the hash will be done to see if an object changed
fn (mut obj User) content4hash() string {
	mut out := obj.id.str() + obj.name + obj.description
	for tag in obj.tags {
		out += tag
	}
	for remark in obj.remarks {
		out += '-' + remark.str()
	}

	return out
}

// IF YOU WANT TO CREATE CUSTOM TABLE IN SQLITE
// [table: 'user_someting']
// struct IndexUserSomething {
// 	id        int    [primary; sql: serial]
//  obj_id	  int
// 	otherproperty      string
// }

// put custom logic here e.g. init the sqlite index if needed, or other initialization
pub fn (mut table TableUser) init() ? {
	// IF NEEDED WITH CUSTOM INDEX
	// indexpath := df.path_data+"/user/index.db"
	// mut db := sqlite.connect(indexpath) ?
	// sql db {
	// 	create table IndexUserSomething
	// }	
	// db.close()?
}

// index for 1 specific object
fn (mut obj User) index_add() ? {
}

// index remove for 1 specific object
fn (mut obj User) index_remove() ? {
}
