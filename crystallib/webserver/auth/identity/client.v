module identity

import net.http
import db.sqlite
import rand
import json

pub struct Client {
	url string @[required]
}

@[post]
pub fn (mut c Client) register(user User) !string {
	data := json.encode(user)
	req := http.new_request(.post, '${c.url}/register', data)
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return resp.body
}

@[post]
pub fn (c Client) get_user(user User) !User {
	data := json.encode(user)
	req := http.new_request(.get, '${c.url}/get_user', data)
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return json.decode(User, resp.body)
}

@[post]
pub fn (c Client) get_users() ![]User {
	println('${c.url}/get_users')
	req := http.new_request(.get, '${c.url}/get_users', '')
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return json.decode([]User, resp.body)
}

pub fn (c Client) get_groups() ![]Group {
	println('${c.url}/get_users')
	req := http.new_request(.get, '${c.url}/get_groups', '')
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return json.decode([]Group, resp.body)
}

@[get]
pub fn (c Client) user_exists(user User) !bool {
	data := json.encode(user)
	req := http.new_request(.post, '${c.url}/user_exists', data)
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
	return resp.body == 'true'
}

pub fn (c Client) create_group(group Group) ! {
	data := json.encode(group)
	req := http.new_request(.post, '${c.url}/create_group', data)
	resp := req.do()!
	if resp.status_code != 200 {
		return error(resp.body)
	}
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
