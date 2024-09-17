module heroweb

import freeflowuniverse.crystallib.core.texttools


pub enum RightEnum {
	block
	read
	write
	admin
}

pub fn (r RightEnum) level() int {
	return int(r)
}

pub struct ACE {
pub mut:
	group string
	user  string
	right RightEnum
}

pub struct ACL {
pub mut:
	name    string
	entries []ACE
}

pub struct User {
pub mut:
	id          u16 // increment as we load it
	name        string
	email       []string
	description string
	profile     string
	admin       bool
}

pub struct Group {
pub mut:
	name   string
	users  []string
	groups []string
}


pub struct InfoPointer {
pub mut:
	name         string
	path         string
    children     []InfoPointer //e.g. to create a folder, there can be a folder in a folder too (but there it stops)
	acl          []string
	description  string
	expiration   string
	acl_resolved map[u16]u8
	cat          InfoType
	slides       ?SlidesViewData
}

pub enum InfoType {
	html
	slides
	pdf
	wiki
}


@[params]
pub struct ACEAddArgs {
pub mut:
	group string
	user  string
	right RightEnum
}

pub fn (mut self ACL) add(args ACEAddArgs) !ACE {
	mut new_ace := ACE{
		group: texttools.name_fix(args.group)
		right: args.right
	}
	for existing in self.entries {
		if existing.group == new_ace.group {
			return error('ACE with group ${new_ace.group} already exists')
		}
		if existing.user == new_ace.user {
			return error('ACE with user ${new_ace.user} already exists')
		}
	}
	self.entries << new_ace
	return new_ace
}

@[params]
pub struct UserAddArgs {
pub mut:
	name        string
	email       string
	description string
	profile     string
	admin       bool
}

pub fn (mut self WebDB) user_add(args UserAddArgs) !&User {
	name := texttools.name_fix(args.name)
	if name in self.users {
		return error('User with name ${name} already exists')
	}
	mut new_user := &User{
		name:        name
		email:       texttools.name_fix_list(args.email)
		description: args.description
		profile:     args.profile
		admin:       args.admin
	}
	self.users[name] = new_user
	return new_user
}

@[params]
pub struct GroupAddArgs {
pub mut:
	name   string
	users  string
	groups string
}

pub fn (mut self WebDB) group_add(args GroupAddArgs) !&Group {
	name := texttools.name_fix(args.name)
	if name in self.groups {
		return error('Group with name ${name} already exists')
	}
	mut new_group := &Group{
		name:   name
		users:  texttools.name_fix_list(args.users)
		groups: texttools.name_fix_list(args.groups)
	}
	self.groups[name] = new_group
	return new_group
}

@[params]
pub struct ACLAddArgs {
pub mut:
	name    string
	entries []ACE
}

pub fn (mut self WebDB) acl_add(args_ ACLAddArgs) !&ACL {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	if args.name in self.acls {
		return error('ACL with name ${args.name} already exists')
	}
	for mut aceobj in args.entries {
		aceobj.group = texttools.name_fix(aceobj.group)
		aceobj.user = texttools.name_fix(aceobj.user)
	}
	mut new_acl := &ACL{
		name:    args.name
		entries: args.entries
	}
	self.acls[args.name] = new_acl
	return new_acl
}


// Example usage
pub fn model_auth_example() ! {
	mut db := WebDB{}

	db.user_add(name: 'john', email: 'john@example.com') or { panic(err) }
	db.group_add(name: 'admins', users: 'john') or { panic(err) }
	db.acl_add(
		name:    'default'
		entries: [ACE{
			group: 'admins'
			right: .admin
		}]
	) or { panic(err) }
	db.infopointer_add(name: 'test', path: '/test', acl: ['default']) or { panic(err) }
	db.infopointer_resolve('test') or { panic(err) }

	println(db)
}



// @[params]
// pub struct ModelAuthNewArgs {
// pub mut:
// 	heroscript string
// }

// // pub fn  model_auth_new(args_ ModelAuthNewArgs) !WebDB  {
//     mut db:=WebDB{}
// 	mut args:=args_
// 	if args.heroscript ==""{
// 		args.heroscript = $tmpl("templates/example_slides.md")
// 	}	
// 	mut plbook := playbook.new(text: args.heroscript)!
// 	mut db := play_auth(mut plbook)!
//     return db
// }

// pub fn model_auth_demo()! {

// 	// Create Slides instance and parse the input
// 	mut db := model_auth_new()!
//     println(db)

//     //TODO: implement the model_auth new

// }
