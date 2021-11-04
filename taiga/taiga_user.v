module taiga
import os
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
		user := user_decode(u.str()) ?
		conn.user_remember(user)
	}
}

pub fn user_get(id int) ?User {
	mut conn :=  connection_get()
	response := conn.get_json_str('users/$id', "", true) ?
	mut result := user_decode(response) ?
	conn.user_remember(result)
	return result
}

//get markdown for all projects per user
fn (mut user User) projects_per_user_md(export_directory string, url string){
	projects := projects_per_user(user.id)
	mut projects_md := []string
	for proj in projects {
		circles_url := url
		project := proj // For template rendering
		stories := stories_per_project(project.id) // For template rendering
		issues := issues_per_project(project.id) // For template rendering
		tasks := tasks_per_project(project.id) // For template rendering
		epics := epics_per_project(project.id) // For template rendering
		// export template per project
		projects_md << $tmpl("./templates/project.md")
	}
	user_md := $tmpl("./templates/user.md")
	export_path := export_directory + "/" + user.username + ".md"
	// export template for user
	os.write_file(export_path,user_md) or {panic(err)}
	println("Exporting Done!")
}

pub fn user_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('users', id) ?
	conn.user_forget(id)
	return response
}

fn user_decode(data string) ?User{
	mut user := json.decode(User, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	user.date_joined = parse_time(data_as_map["date_joined"].str())
	return user
}

