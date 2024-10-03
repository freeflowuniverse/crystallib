
module heroweb

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console

pub fn (mut db WebDB) play_authorization (mut plbook playbook.PlayBook) !WebDB {

	// Process all webdb actions

	webdb_actions := plbook.find(filter: 'webdb.user_add')!
	for action in webdb_actions {
		db.user_add(
			name:        action.params.get_default('name', '')!
			email:       action.params.get('email')!
			description: action.params.get_default('description', '')!
			profile:     action.params.get_default('profile', '')!
			admin:       action.params.get_default_false('admin')
		) or { return error('Failed to add user: ${err}') }
	}

	webdb_actions2 := plbook.find(filter: 'webdb.group_add')!
	for action in webdb_actions2 {

		// this allows adding user to group by name, email or id, since all are unique
		users := action.params.get_list_default('users', [])!
		mut user_ids := []u16{}
		for user in users {
			if user.is_int() {
				user_ids << user.u16()
				continue
			}
			user_ids << db.get_user_id(name: user, email: [user]) or {
				continue
			}
		}

		db.group_add(
			name:   action.params.get('name')!
			user_ids: user_ids
			groups: action.params.get_default('groups', '')!
		) or { return error('Failed to add user: ${err}') }
	}

	webdb_actions3 := plbook.find(filter: 'webdb.acl_add')!
	for action in webdb_actions3 {
		db.acl_add(
			name:    action.params.get_default('name', '')!
			entries: [] // We'll add ACEs separately
		) or { return error('Failed to add ACL: ${err}') }
	}

	webdb_actions4 := plbook.find(filter: 'webdb.ace_add')!
	for action in webdb_actions4 {
	    acl_name := texttools.name_fix(action.params.get_default('acl', '')!)
	    mut acl := db.acls[acl_name] or { return error('ACL ${acl_name} not found') }
	        
		group := texttools.name_fix(action.params.get_default('group', '')!)
		if (group != '' && group != 'public') && group !in db.groups {
			return error('Group with name ${group} not found')
		}

		user := action.params.get_default('user', '')!
		mut user_id := if user == '' {u16(0)
		} else if user.is_int() {
			user.u16()
		} else {
			db.get_user_id(name: user, email: [user]) or {
				return error('user ${user} not found')
			}
		}

		right_str := texttools.name_fix(action.params.get_default('right', '')!)

		acl.add(group: group,
			user: user_id,
			right: RightEnum.from_string(right_str) or {return error(err.str())}
		) or { return error('Failed to add ACE: ${err}') }
	
	}
	println('db.users ${db.users}')

	return db
}
