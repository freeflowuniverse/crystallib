module model

import sqlite

//Data object for user
pub struct User {
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

[table: 'user']
struct IndexUser {
	id        int    [primary; sql: serial]
	name      string
	description string
	tags string
}

[table: 'user_tags']
struct IndexUserTags {
	i_        int    [primary; sql: serial]
	id        int    
	tag      string
}

//produce the content on which the hash will be done to see if an object changed
fn (mut obj User) content4hash() string {
	mut out := obj.id.str()+obj.name+obj.description
	for tag in obj.tags{
		out+=tag
	}
	for remark in obj.remarks{
		out+="-"+remark.str()
	}

	return out
}

