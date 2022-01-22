module taiga

import despiegk.crystallib.texttools
import despiegk.crystallib.crystaljson
import json
import time { Time }
import math { pow10 }
// import x.json2 { raw_decode }

pub struct User {
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
	date_joined       Time     [skip]
	file_name         string   [skip]
}

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

// //get markdown for all projects per user	
// fn (mut u User) projects_per_user_md() string{

// 	//TODO: implement template :projects_per_user.md
// 	//walk over stories for user, show tasks, show comments

// 	//see: https://github.com/vlang/v/blob/master/doc/docs.md#tmpl-for-embedding-and-parsing-v-template-files

// get markdown for all projects per user
pub fn (user User) as_md(url string) string {
	time_now := time.now()
	// Init render variables
	mut blocked := ProjectElements{} // For template rendering
	mut overdue := ProjectElements{} // For template rendering
	mut today := ProjectElements{} // For template rendering
	mut in_two_days := ProjectElements{} // For template rendering
	mut in_week := ProjectElements{} // For template rendering
	mut in_month := ProjectElements{} // For template rendering
	mut others := ProjectElements{} // For template rendering
	mut old := ProjectElements{} // For template rendering

	// Init local variables
	mut stories := []Story{}
	mut issues := []Issue{}
	mut tasks := []Task{}
	mut epics := []Epic{}

	// Get all user projects
	projects := projects_per_user(user.id)
	for proj in projects {
		stories << stories_per_project(proj.id)
		issues << issues_per_project(proj.id)
		tasks << tasks_per_project(proj.id)
		epics << epics_per_project(proj.id)
	}

	for story in stories {
		if story.is_blocked {
			blocked.stories << story
		} else if story.due_date != Time{} {
			d_time := (story.due_date - time_now) / (pow10(9) * 3600 * 24) // difference between story due_time and time now in days.
			if d_time < -60 {
				old.stories << story
			} else if d_time < 0 {
				overdue.stories << story
			} else if d_time <= 1 {
				today.stories << story
			} else if d_time <= 2 {
				in_two_days.stories << story
			} else if d_time <= 7 {
				in_week.stories << story
			} else if d_time <= 30 {
				in_month.stories << story
			}
		} else {
			others.stories << story
		}
	}

	for issue in issues {
		if issue.is_blocked {
			blocked.issues << issue
		} else if issue.due_date != Time{} {
			d_time := (issue.due_date - time_now) / (pow10(9) * 3600 * 24) // difference between issue due_time and time now in days.
			if d_time < -60 {
				old.issues << issue
			} else if d_time < 0 {
				overdue.issues << issue
			} else if d_time <= 1 {
				today.issues << issue
			} else if d_time <= 2 {
				in_two_days.issues << issue
			} else if d_time <= 7 {
				in_week.issues << issue
			} else if d_time <= 30 {
				in_month.issues << issue
			}
		} else {
			others.issues << issue
		}
	}

	for task in tasks {
		if task.is_blocked {
			blocked.tasks << task
		} else if task.due_date != Time{} {
			d_time := (task.due_date - time_now) / (pow10(9) * 3600 * 24) // difference between task due_time and time now in days.
			if d_time < -60 {
				old.tasks << task
			} else if d_time < 0 {
				overdue.tasks << task
			} else if d_time <= 1 {
				today.tasks << task
			} else if d_time <= 2 {
				in_two_days.tasks << task
			} else if d_time <= 7 {
				in_week.tasks << task
			} else if d_time <= 30 {
				in_month.tasks << task
			}
		} else {
			others.tasks << task
		}
	}

	mut user_md := $tmpl('./templates/user.md')
	user_md = fix_empty_lines(user_md)
	return user_md
}

pub fn user_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('users', id) ?
	conn.user_forget(id)
	return response
}

fn user_decode(data string) ?User {
	mut user := json.decode(User, data) or {
		return error('Error happen when decode user\nData: $data\nError:$err')
	}
	data_as_map := crystaljson.json_dict_any(data,false,[],[])?
	user.date_joined = parse_time(data_as_map['date_joined'].str())
	user.file_name = texttools.name_clean(user.username) + '.md'
	return user
}
