module taiga

import json

struct User {
pub mut:
	id                int
	is_active         bool
	username          string
	full_name         string
	full_name_display string
	bio               string
	photo             string
	roles             []string
	email             string
	public_key        string
	date_joined       string
}

fn (mut h TaigaConnection) users() ?[]User {
	mut conn := connection_get()	
	data := conn.get_json_str('users', '', true) ?
	return json.decode([]User, data) or {}
}
