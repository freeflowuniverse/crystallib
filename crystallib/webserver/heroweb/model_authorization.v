#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

module heroweb

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

@[params]
pub struct ACEAddArgs {
pub mut:
    group string
    user  u16
    right RightEnum
}

pub fn (mut self ACL) add(args ACEAddArgs) !ACE {
    mut new_ace := ACE{
        user: args.user
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

// either registers user, or logs user in
pub fn (mut self WebDB) register_login(email string) !u16 {
    if self.users.values().any(email in it.email) {
        return self.get_user_id(email: [email])!
    }
    return self.user_add(email: email)!
}

pub fn (mut self WebDB) user_add(args UserAddArgs) !u16 {
    name := texttools.name_fix(args.name)
    if self.users.values().any(name == it.name) {
        return error('User with name ${name} already exists')
    }
    if self.users.values().any(args.email in it.email) {
        return error('User with email ${args.email} already exists')
    }
    mut new_user := &User{
        name: name
        email: [texttools.email_fix(args.email)!]
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
    groups string
}

pub fn (mut self WebDB) new_user(user User) u16 {
    id := u16(self.users.keys().len + 1)
    self.users[id] = &User{...user, id: id}
    return id
}

pub fn (self WebDB) get_user_id(user User) ?u16 {
    matches := self.users.values().filter((it.name != '' && it.name == user.name) || it.email == user.email)
    if matches.len == 0 {return none}
    if matches.len == 1 {
        return matches[0].id
    }
    panic('user names and emails should be uniqe, this should never happen')
}

pub fn (mut self WebDB) group_add(args GroupAddArgs) !&Group {
    name := texttools.name_fix(args.name)
    if name in self.groups {
        return error('Group with name ${name} already exists')
    }

    mut new_group := &Group{
        name: name
        users: args.user_ids
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
        aceobj.user = aceobj.user
    }
    mut new_acl := &ACL{
        name: args.name
        entries: args.entries
    }
    self.acls[args.name] = new_acl
    return new_acl
}


pub struct AuthorizationRequest {
pub:
    right RightEnum 
    subject u16 // subject attempting to be authorized
    object string // object for which authorization is being attempted 
}

pub fn (db WebDB) authorize(request AuthorizationRequest) !bool {
    // public right is greater than requested right
    if u8(db.public_right(request.object)!) >= u8(request.right) {
        return true
    }
    acl_resolved := db.infopointer_resolve(request.object)!

    if request.object !in db.infopointers {
        // QUESTION: expected behaviour?
        return error('Access control for resource ${request.object} not found')
    }

    if request.subject !in acl_resolved {
        return false
    }

    return acl_resolved[request.subject] >= u8(request.right)
}

pub fn (mut db WebDB) authorized_ptrs(subject u16, right RightEnum) ![]InfoPointer {
    mut ptrs := []InfoPointer
    for key, ptr in db.infopointers {
        if db.authorize(
            subject: subject
            object: key
            right: right
        )! {
            ptrs << ptr
        }
    }
    return ptrs
}

// Example usage
pub fn model_auth_example()!{
    mut db := WebDB{}

    id := db.user_add(name: 'john', email: 'john@example.com') or { panic(err) }
    db.group_add(name: 'admins', user_ids: [id]) or { panic(err) }
    db.acl_add(name: 'default', entries: [ACE{group: 'admins', right: .admin}]) or { panic(err) }
    db.infopointer_add(name: 'test', path_content: '/test', acl: ['default']) or { panic(err) }
    db.infopointer_resolve('test') or { panic(err) }

    println(db)
}


@[params]
pub struct ModelAuthNewArgs {
pub mut:
	heroscript string
}

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