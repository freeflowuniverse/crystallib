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
	date_joined       Time
}

pub fn users() ?[]User {
	mut conn := connection_get()	
	data := conn.get_json_str('users', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	mut users := []User{}
	for u in data_as_arr {
		user := user_decode(u.str()) ?
		user_remember(user)
		users << user
	}
	return users
}


//get markdown for all projects per user
fn (mut u User) projects() ?[]Project {

	//for further development just fake
	//TODO: implement

	mut ps := []Project{}
	ps << Project{name:"a name",description:"A Description\n\nline1\nline2\n"}
	
	return ps

}



//get markdown for all projects per user
fn (mut u User) projects_per_user_md() string{

	//TODO: implement template :projects_per_user.md
	//walk over stories for user, show tasks, show comments
	
	return ""
}

fn user_decode(data string) ?User{
	mut user := json.decode(User, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	user.date_joined = parse_time(data_as_map["date_joined"].str())
	return user
}

