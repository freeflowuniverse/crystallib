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



