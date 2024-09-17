
module heroweb

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console

pub fn (mut db WebDB)  play_auth(mut plbook playbook.PlayBook) !WebDB {

	// Process all webdb actions

	webdb_actions := plbook.find(filter: 'webdb.user_add')!
	for action in webdb_actions {
		db.user_add(
			name:        action.params.get('name')!
			email:       action.params.get('email')!
			description: action.params.get_default('description', '')!
			profile:     action.params.get_default('profile', '')!
			admin:       action.params.get_default_false('admin')
		) or { return error('Failed to add user: ${err}') }
	}

	webdb_actions2 := plbook.find(filter: 'webdb.group_add')!
	for action in webdb_actions2 {
		db.group_add(
			name:   action.params.get('name')!
			users:  action.params.get_default('users', '')!
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

	// TODO:
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


	return db
}
