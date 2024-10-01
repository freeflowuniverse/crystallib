module heroweb


import freeflowuniverse.crystallib.ui.console

import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.medium.slides


struct Document {
	title string
	description string
	tags []string
	url string
	creator string
	date_created string
	order int
	format string
	kind string
}

pub struct InfoPointer {
pub mut:
	name         string
	path_content         string
	path_heroscript         string
    children     []InfoPointer //e.g. to create a folder, there can be a folder in a folder too (but there it stops)
	acl          []string
	tags []string
	description  string
	expiration   string
	acl_resolved map[u16]u8
	cat          InfoType
	// slides       ?SlidesViewData
	dagu 		 bool //not used for now, is when we will run the hero actions in dagu
}

pub enum InfoType {
	html
	slides
	pdf
	wiki
	website
	folder
	book
}

@[params]
pub struct InfoPointerAddArgs {
pub mut:
	name        string
	path_content        string
	path_heroscript        string
	cat        InfoType
	acl         []string
	tags []string
	description string
	expiration  string
}

pub fn (mut self WebDB) infopointer_add(args InfoPointerAddArgs) !&InfoPointer {
	name := texttools.name_fix(args.name)
	if name in self.infopointers {
		return error('InfoPointer with name ${name} already exists')
	}
	mut new_infopointer := &InfoPointer{
		name:        name
		path_content:        args.path_content
		path_heroscript:        args.path_heroscript
		cat:        args.cat
		acl:         args.acl.map(texttools.name_fix)
		tags:         args.tags.map(texttools.name_fix)
		description: args.description
		expiration:  args.expiration
	}
	// Check if the ACL exists based on name
	if args.acl[0] !in self.acls {
		return error('ACL with name ${args.acl[0]} does not exist')
	}
	self.infopointers[name] = new_infopointer
	return new_infopointer
}

pub fn (db WebDB) public_right(info_name string) !RightEnum {
	mut info := db.infopointers[info_name] or { return error('InfoPointer ${info_name} not found') }
	acl_name := info.acl[0]
	mut acl := db.acls[acl_name] or { return error('ACL not found for InfoPointer ${info_name}') }
	public_ace := acl.entries.filter(it.group == 'public')
	if public_ace.len == 0 {
		return .block
	}
	return public_ace[0].right
}

pub fn (db WebDB) infopointer_resolve(info_name string) !map[u16]u8 {
	mut info := db.infopointers[info_name] or { return error('InfoPointer ${info_name} not found') }
	mut users := map[u16]u8{}

	acl_name := info.acl[0]
	mut acl := db.acls[acl_name] or { return error('ACL not found for InfoPointer ${info_name}') }

	for ace in acl.entries {
		if ace.group != '' {
			group := db.groups[ace.group] or {
				continue // Skip if group not found
			}
			for id in group.users {
				users[id] = u8(max(users[id] or { 0 }, ace.right.level()))
			}
			for subgroup_name in group.groups {
				subgroup := db.groups[subgroup_name] or {
					continue // Skip if subgroup not found
				}
				for user_name in subgroup.users {
					thisuser := db.users[user_name] or { panic('bug') }
					users[thisuser.id] = u8(max(users[thisuser.id] or { 0 }, ace.right.level()))
				}
			}
		}
		if ace.user != 0 {
			thisuser := db.users[ace.user] or { panic('bug') }
			users[thisuser.id] = u8(max(users[thisuser.id] or { 0 }, ace.right.level()))
		}
	}

	return users
}

//run the heroscript
pub fn (mut db WebDB) infopointer_run(info_name string) ! {
	mut info := db.infopointers[info_name] or { return error('InfoPointer ${info_name} not found') }

	if info.path_heroscript.len==0{
		return
	}

	mut plbook := playbook.new(path: info.path_heroscript)!

	if info.cat == .slides && !info.path_content.ends_with('.pdf') {
		db.slides[info_name] = slides.play(mut plbook)!
	} else {
		playcmds.run(mut plbook, info.dagu)!
	}

	console.print_stdout(plbook.str())	
}

fn max(a int, b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}

// @[params]
// pub struct ModelAuthNewArgs {
// pub mut:
// 	heroscript string
// }

// pub fn  model_auth_new(args_ ModelAuthNewArgs) !WebDB  {
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
