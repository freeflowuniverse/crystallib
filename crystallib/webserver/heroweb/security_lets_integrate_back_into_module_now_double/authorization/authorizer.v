#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

module authorization

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.playbook


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
    user  u16
    right RightEnum
}

pub struct ACL {
pub mut:
    name    string
    entries []ACE
}

pub struct User {
pub mut:
    id          u16 //increment as we load it
    name        string
    email       []string
    description string
    profile     string
    admin       bool
}

pub struct Group {
pub mut:
    name   string
    users  []u16
    groups []string
}

pub struct InfoPointer {
pub mut:
    name         string
    path         string
    acl          []string
    description  string
    expiration   string
    acl_resolved map[u16]u8 //TODO, need to use index towards the user, not the email address
}

pub struct Authorizer {
pub mut:
    users        map[u16]&User
    groups       map[string]&Group
    acls         map[string]&ACL
    infopointers map[string]&InfoPointer
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

pub fn (mut self Authorizer) user_add(args UserAddArgs) !u16 {
    name := texttools.name_fix(args.name)
    if self.users.values().any(name == it.name) {
        return error('User with name ${name} already exists')
    }
    if self.users.values().any(args.email in it.email) {
        return error('User with email ${args.email} already exists')
    }
    mut new_user := &User{
        name: name
        email: texttools.name_fix_list(args.email)
        description: args.description
        profile: args.profile
        admin: args.admin
    }
    return self.new_user(new_user)
}

@[params]
pub struct GroupAddArgs {
pub mut:
    name   string
    user_ids  []u16
    user_names  []string
    groups string
}

pub fn (mut self Authorizer) new_user(user User) u16 {
    id := u16(self.users.keys().len + 1)
    self.users[id] = &User{...user, id: id}
    return id
}

pub fn (self Authorizer) get_user_id(user User) ?u16 {
    matches := self.users.values().filter(it.name == user.name || it.email == user.email)
    if matches.len == 0 {return none}
    if matches.len == 1 {
        return matches[0].id
    }
    panic('user names and emails should be uniqe, this should never happen')
}

pub fn (mut self Authorizer) group_add(args GroupAddArgs) !&Group {
    name := texttools.name_fix(args.name)
    if name in self.groups {
        return error('Group with name ${name} already exists')
    }

    mut user_ids := args.user_ids.clone()
    for user_name in args.user_names {
        id := self.get_user_id(
            name: texttools.name_fix(user_name)
        ) or {continue}
        user_ids << id
    }

    mut new_group := &Group{
        name: name
        users: user_ids
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

pub fn (mut self Authorizer) acl_add(args_ ACLAddArgs) !&ACL {
    mut args := args_
    args.name = texttools.name_fix(args.name)
    if args.name in self.acls {
        return error('ACL with name ${args.name} already exists')
    }
    for mut aceobj in args.entries {
        aceobj.group = texttools.name_fix(aceobj.group)
        aceobj.user = aceobj.user
    }
    mut new_acl := &ACL{
        name: args.name
        entries: args.entries
    }
    self.acls[args.name] = new_acl
    return new_acl
}

@[params]
pub struct InfoPointerAddArgs {
pub mut:
    name        string
    path        string
    acl         []string
    description string
    expiration  string
}

pub fn (mut self Authorizer) infopointer_add(args InfoPointerAddArgs) !&InfoPointer {
    name := texttools.name_fix(args.name)
    if name in self.infopointers {
        return error('InfoPointer with name ${name} already exists')
    }
    mut new_infopointer := &InfoPointer{
        name: name
        path: args.path
        acl: args.acl.map(texttools.name_fix)
        description: args.description
        expiration: args.expiration
    }
    // Check if the ACL exists based on name
    if args.acl[0] !in self.acls {
        return error('ACL with name ${args.acl[0]} does not exist')
    }
    self.infopointers[name] = new_infopointer
    return new_infopointer
}

pub fn (mut db Authorizer) infopointer_resolve(info_name string) ! {
    mut info := db.infopointers[info_name] or {
        return error('InfoPointer ${info_name} not found')
    }
    mut users := map[u16]u8{}
    
    acl_name := info.acl[0]
    mut acl := db.acls[acl_name] or {
        return error('ACL not found for InfoPointer ${info_name}')
    }

    for ace in acl.entries {
        if ace.group != "" {
            group := db.groups[ace.group] or {
                continue // Skip if group not found
            }
            for user_name in group.users {
                users[user_name] = u8(max(users[user_name] or { 0 }, ace.right.level()))
            }
            for subgroup_name in group.groups {
                subgroup := db.groups[subgroup_name] or {
                    continue // Skip if subgroup not found
                }
                for user_name in subgroup.users {
                    users[user_name] = u8(max(users[user_name] or { 0 }, ace.right.level()))
                }
            }
        }
        if ace.user != 0 {
            users[ace.user] = u8(max(users[ace.user] or { 0 }, ace.right.level()))
        }
    }

    info.acl_resolved = &users
}

pub struct AuthorizationRequest {
pub:
    right RightEnum 
    subject u16 // subject attempting to be authorized
    object string // object for which authorization is being attempted 
}

pub fn (mut db Authorizer) authorize(request AuthorizationRequest) !bool {
    db.infopointer_resolve(request.object)!

    if request.object !in db.infopointers {
        // QUESTION: expected behaviour?
        return error('Access control for resource ${request.object} not found')
    }

    if request.subject !in db.infopointers[request.object].acl_resolved {
        return false
    }

    return db.infopointers[request.object].acl_resolved[request.subject] >= u8(request.right)
}

fn max(a int, b int) int {
    if a > b {
        return a
    } else {
        return b
    }
}


// Example usage
pub fn model_auth_example()!{
    mut db := Authorizer{}

    db.user_add(name: 'john', email: 'john@example.com') or { panic(err) }
    db.group_add(name: 'admins', user_names: ['john']) or { panic(err) }
    db.acl_add(name: 'default', entries: [ACE{group: 'admins', right: .admin}]) or { panic(err) }
    db.infopointer_add(name: 'test', path: '/test', acl: ['default']) or { panic(err) }
    db.infopointer_resolve('test') or { panic(err) }

    println(db)
}


@[params]
pub struct ModelAuthNewArgs {
pub mut:
	heroscript string
}

pub fn play_auth(mut plbook playbook.PlayBook) !Authorizer {
    mut db := Authorizer{}

    // Process all webdb actions

    webdb_actions := plbook.find(filter: 'webdb.user_add')!
    for action in webdb_actions {
        db.user_add(
            name: action.params.get('name')!
            email: action.params.get('email')!
            description: action.params.get_default('description', '')!
            profile: action.params.get_default('profile', '')!
            admin: action.params.get_default_false('admin')
        ) or { return error('Failed to add user: ${err}') }
    }

    webdb_actions2 := plbook.find(filter: 'webdb.group_add')!
    for action in webdb_actions2 {
        db.group_add(
                name: action.params.get('name')!
                user_names: action.params.get_list_default('user_names', [])!
                user_ids: action.params.get_list_u16_default('user_ids', [])
                groups: action.params.get_default('groups', '')!
        ) or { return error('Failed to add user: ${err}') }
    }

    webdb_actions3 := plbook.find(filter: 'webdb.acl_add')!
    for action in webdb_actions3 {
        db.acl_add(
            name: action.params.get_default('name', '')!
            entries: [] // We'll add ACEs separately
        ) or { return error('Failed to add ACL: ${err}') }
    }

    // webdb_actions4 := plbook.find(filter: 'webdb.ace_add')!
    // for action in webdb_actions4 {
    //     acl_name := action.params.get_default('acl', '')!
    //     mut acl := db.acls[acl_name] or { return error('ACL ${acl_name} not found') }
    //     acl.add(
    //         group: action.params.get_default('group', '')!
    //         user: action.params.get_default('user', '')?
    //         right: RightEnum(action.params.get_default('right', '')
    //     ) or { return error('Failed to add ACE: ${err}') }

    // }

    // webdb_actions5 := plbook.find(filter: 'webdb.infopointer_add')!
    // for action in webdb_actions5 {
    //         db.infopointer_add(
    //             name: action.params.get_default('name', '')!
    //             path: action.params.get_default('path', '')!
    //             acl: action.params.get_list('acl')!
    //             description: action.params.get_default('description', '')!
    //             expiration: action.params.get_default('expiration', '')!
    //         ) or { return error('Failed to add InfoPointer: ${err}') }
    // }

    return db
}

// pub fn  model_auth_new(args_ ModelAuthNewArgs) !Authorizer  {
//     mut db:=Authorizer{}
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