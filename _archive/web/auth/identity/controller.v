module identity

import vweb
import db.sqlite
import rand
import json
import freeflowuniverse.crystallib.ui.console

pub struct Controller {
	vweb.Context
pub mut:
	db sqlite.DB
}

pub fn (mut ctrl Controller) before_request() {
	console.print_debug(ctrl.req)
}

@[post]
pub fn (mut ctrl Controller) register() vweb.Result {
	user_ := json.decode(User, ctrl.req.data) or {
		ctrl.set_status(400, '')
		return ctrl.text('Failed to decode request data.')
	}

	user := User{
		...user_
		id: rand.uuid_v4()
	}

	sql ctrl.db {
		insert user into User
	} or {
		ctrl.set_status(500, '')
		return ctrl.text('Failed insert user ${user} into db.')
	}

	return ctrl.text(user.id)
}

@[post]
pub fn (mut ctrl Controller) create_group() vweb.Result {
	group := json.decode(Group, ctrl.req.data) or {
		ctrl.set_status(400, '')
		return ctrl.text('Failed to decode request data.')
	}

	// TODO: check group with name doesnt exist
	sql ctrl.db {
		insert group into Group
	} or {
		ctrl.set_status(500, '')
		return ctrl.text('Failed to insert group ${group} into db.')
	}

	return ctrl.text('')
}

pub fn (mut ctrl Controller) get_users() vweb.Result {
	users := sql ctrl.db {
		select from User
	} or {
		ctrl.set_status(500, '')
		return ctrl.text('Failed to get users from db.')
	}
	return ctrl.json(users)
}

pub fn (mut ctrl Controller) get_groups() vweb.Result {
	groups := sql ctrl.db {
		select from Group
	} or {
		ctrl.set_status(500, '')
		return ctrl.text('Failed to get users from db.')
	}
	return ctrl.json(groups)
}

// [get]
// pub fn (mut ctrl Controller) logs() vweb.Result {
// 	logs := sql ctrl.db {
// 		select from Log
// 	} or {
// 		ctrl.set_status(500, '')
// 		return ctrl.text('Failed insert log into db.')
// 	}
// 	return ctrl.json(logs)
// }
