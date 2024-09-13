module authorization

import freeflowuniverse.crystallib.baobab.actor


pub enum Permission {
	@none
	read
	write
}

pub struct Authorizer {
	actor.Actor
}

// Role represents a user's role in the system
pub struct Role {
pub:
    name        string
    permissions []Permission
}

pub struct AccessControl {
pub mut:
	id u32
pub:
	resource string
	owner string
	permissions []Permission
	user_acl []AccessControlEntry
	role_acl []AccessControlEntry
}

pub struct AccessControlEntry {
pub:
	user_id string
	permissions []Permission
}

pub fn (mut a Authorizer) add_access_control(object AccessControl) ! {
	a.backend.generic_new[AccessControl](object)!
}

pub fn (mut a Authorizer) get_user_resource_permissions(user string, resource string) ![]Permission {
	mut permissions := []Permission{}
	
	mut controls := a.backend.generic_list[AccessControl]()!
	resource_controls := controls.filter(it.resource == resource)
	if resource_controls.len < 1 {
		return permissions
	}
	if resource_controls.len > 1 {
		panic('error, this should never happpen')
	}

	user_aces := resource_controls[0].user_acl.filter(it.user_id == user)
	if user_aces.len < 1 {
		return resource_controls[0].permissions
	}
	if user_aces.len > 1 {
		panic('error, this should never happpen')
	}

	return user_aces[0].permissions
}

pub fn (mut a Authorizer) get_user_permissions(user string) !map[string][]Permission {
	mut controls := a.backend.generic_list[AccessControl]()!
	
	mut permissions := map[string][]Permission{}
	for control in controls {
		permissions[control.resource] = a.get_user_resource_permissions(user, control.resource)!
	}

	return permissions
}