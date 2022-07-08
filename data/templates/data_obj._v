module model

import sqlite

//Data object for $name
pub struct ${name.capitalize()} {
pub mut:
	id          int
	name        string
	description string
	tags		[]string
	remarks		[]int
	contentkey	string
	changed bool 						[skip]
	//last used from memory, this to let cache work
	access_last	int						[skip]
	table 	&Table${name.capitalize()} 	[skip]
}


//produce the content on which the hash will be done to see if an object changed
fn (mut obj ${name.capitalize()}) content4hash() string {
	mut out := obj.id.str()+obj.name+obj.description
	for tag in obj.tags{
		out+=tag
	}
	for remark in obj.remarks{
		out+="-"+remark.str()
	}

	return out
}

//IF YOU WANT TO CREATE CUSTOM TABLE IN SQLITE
// [table: '${name}_someting']
// struct Index${name.capitalize()}Something {
// 	id        int    [primary; sql: serial]
//  obj_id	  int
// 	otherproperty      string
// }

//put custom logic here e.g. init the sqlite index if needed, or other initialization
pub fn (mut table Table${name.capitalize()})  init() ? {

	//IF NEEDED WITH CUSTOM INDEX
	// indexpath := df.path_data+"/${name}/index.db"
	// mut db := sqlite.connect(indexpath) ?
	// sql db {
	// 	create table Index${name.capitalize()}Something
	// }	
	// db.close()?

}

//index for 1 specific object
fn (mut obj ${name.capitalize()}) index_add() ? {

}

//index remove for 1 specific object
fn (mut obj ${name.capitalize()}) index_remove() ? {

}
