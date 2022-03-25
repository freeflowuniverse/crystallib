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
	changed bool 	[skip]
	//last used from memory, this to let cache work
	last	int		[skip]
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
// 	i_        int    [primary; sql: serial]
// 	otherproperty      string
// }

//put custom logic here e.g. init the sqlite index if needed, or other initialization
pub fn (mut df DataFactory) ${name}_init_() ? {

	//IF NEEDED WITH CUSTOM INDEX
	// indexpath := df.path_data+"/${name}/index.db"
	// mut db := sqlite.connect(indexpath) ?
	// sql db {
	// 	create table Index${name.capitalize()}Something
	// }	
	// db.close()?

}