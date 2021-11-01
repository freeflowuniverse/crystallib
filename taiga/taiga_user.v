module taiga

import json
import time {Time}
import x.json2 {raw_decode}

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
	date_joined       Time [skip]
}

pub fn users() ? {
	mut conn := connection_get()
	data := conn.get_json_str('users', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	for u in data_as_arr {
		user := decode_user(u.str()) ?
		user_remember(user)
	}
}

//get markdown for all projects per user
fn (mut u User) projects_per_user_md() string{
	projects := projects_per_user(u.id)
	for proj in projects {
		stories := stories_per_project(proj.id)
		issues := issues_per_project(proj.id)
		tasks := tasks_per_project(proj.id)
		epics := epics_per_project(proj.id)
		println("Done!")
	}
	return ""
}

fn decode_user(data string) ?User{
	mut user := json.decode(User, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	user.date_joined = parse_time(data_as_map["date_joined"].str())
	return user
}

