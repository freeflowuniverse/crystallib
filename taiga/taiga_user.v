module taiga

import despiegk.crystallib.texttools
import despiegk.crystallib.crystaljson

pub fn users() ? {
	mut conn := connection_get()
	blocks := conn.get_json_list('users', '', true) ?
	for u in blocks {
		user := user_decode(u.str()) or {
			println(err)
			User{}
		}
		if user != User{} {
			conn.user_remember(user)
		}
	}
}

pub fn user_get(id int) ?User {
	mut conn := connection_get()
	response := conn.get_json_str('users/$id', '', true) ?
	mut result := user_decode(response) ?
	conn.user_remember(result)
	return result
}

pub fn user_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('users', id) ?
	conn.user_forget(id)
	return response
}

fn user_decode(data string) ?User {
	data_as_map := crystaljson.json_dict_any(data, false, [], []) ?
	mut user := User{
		id: data_as_map['id'].int()
		is_active: data_as_map['is_active'].bool()
		username: data_as_map['username'].str()
		full_name: data_as_map['full_name'].str()
		full_name_display: data_as_map['full_name_display'].str()
		bio: data_as_map['bio'].str()
		photo: data_as_map['photo'].str()
		email: data_as_map['email'].str()
		public_key: data_as_map['public_key'].str()
	}
	user.date_joined = parse_time(data_as_map['date_joined'].str())
	user.file_name = texttools.name_clean(user.username) + '.md'
	user.file_name = texttools.ascii_clean(user.file_name)
	return user
}

fn (user User) projects() []Project {
	mut conn := connection_get()
	mut all_user_projects := []Project{}
	for id in conn.projects.keys() {
		proj := *conn.projects[id]
		if user.id in proj.members {
			all_user_projects << proj
		}
	}
	return all_user_projects
}

// get markdown for all projects per user
pub fn (user User) as_md(url string) string {
	mut projects := user.projects()
	mut stories := []Story{}
	mut issues := []Issue{}
	mut tasks := []Task{}
	mut epics := []Epic{}
	for p in projects {
		stories << p.stories()
		issues << p.issues()
		tasks << p.tasks()
		epics << p.epics()
	}
	mut user_md := $tmpl('./templates/user.md')
	user_md = fix_empty_lines(user_md)
	return user_md
}
