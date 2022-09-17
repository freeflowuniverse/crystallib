module publisher2

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

enum SiteType {
	book //mdbook
	wiki
	web //just html
}



enum State {
	ok
	error
	reset
}

[heap]
pub struct Publisher {
pub mut:
	// node  &builder.Node
	state State
	sites map[string]Site //the key is the prefix as used on webserver
	groups map[string]Group
	users map[string]User
}

fn (mut p Publisher) user_add(name_ string) &User{
	mut name:=texttools.name_fix(name_)
	mut u:=User{name:name}
	p.users[name]=u
	return &u

}

fn (mut p Publisher) group_add(name_ string) &Group{
	mut name:=texttools.name_fix(name_)
	mut u:=Group{name:name}
	p.groups[name]=u
	return &u

}

fn (mut p Publisher) site_add(name_ string, type_ SiteType) &Site{
	mut name:=texttools.name_fix(name_)
	mut u:=Site{name:name,publisher:&p,sitetype:type_}
	p.sites[name]=u
	return &u
}


[heap]
pub struct Site {
pub:
	name     string //correspond to key, uses namefix from texttoolsmap[string]Page
	publisher    &Publisher   [str: skip] // pointer to sites
	sitetype SiteType
pub mut:
	path   pathlib.Path //path where site can be found
	authentication Authentication
}

//if acl not empty then is obliged to use, if email required email need to match USER and the ACE/ACL
//if in combination with email_authenticated, it means we make sure that email is correct, so becomes string
//in future will be compatible with TFConnect
[heap]
pub struct Authentication {
pub:
	email_required bool			//if true means users need to give their email address (just a form)
	email_authenticated bool 	//if true, means user needs to give email address and verify the correctness with email client
	tfconnect bool		//not used now for future
	kyc	bool			//not used now for future
	acl	   []ACL		//list of people who have access, can be empty if empty there can be passwd
}

//Access Control List
[heap]
pub struct ACL {
pub mut:
	entries []ACE
}

//Access Control Entry
[heap]
pub struct ACE {
pub mut:
	groups []&Group  //pointer to the object as is in the publisher one
	users []&User   //can be or a user or a group
	right Right
}

[heap]
pub struct Group {
pub:
	name string
pub mut:
	users []&User
}

[heap]
pub struct User {
pub:
	name string
pub mut:
	emails []string
	pubkeys []string //optional
	sshkeys []string //optional
}



//we just go for these 2 for now
enum Right {
	read
	block
}

