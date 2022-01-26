module taiga

import despiegk.crystallib.crystaljson
import json
import x.json2
import os
import math { min }

pub fn tasks() ? {
	mut conn := connection_get()
	resp := conn.get_json_str('tasks', '', true) ?
	raw_data := json2.raw_decode(resp.replace("\\\\", "")) ?
	blocks := raw_data.arr()
	os.write_file("/tmp/taiga_blocks/tasks", "$blocks") ?
	println('[+] Loading $blocks.len tasks ...')
	for t in blocks {
		mut task := Task{}
		task = task_decode(t.str()) or {
			eprintln(err)
			Task{}
		}
		if task != Task{} {
			conn.task_remember(task)
		}
	}
}

// get comments in lis from task
pub fn (mut t Task) comments() ?[]Comment {
	t.comments = comments_get('task', t.id) ?
	return t.comments
}

pub fn task_create(subject string, project_id int) ?Task {
	mut conn := connection_get()
	task := NewTask{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(task)
	response := conn.post_json_str('tasks', postdata, true) ?
	mut result := task_decode(response) ?
	conn.task_remember(result)
	return result
}

pub fn task_get(id int) ?Task {
	mut conn := connection_get()
	response := conn.get_json_str('tasks/$id', '', true) ?
	mut result := task_decode(response) ?
	conn.task_remember(result)
	return result
}

pub fn task_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('tasks', id) ?
	conn.task_forget(id)
	return response
}

fn task_decode(data string) ?Task {
	data_as_map := crystaljson.json_dict_any(data, false, [], []) ?
	projname := data_as_map['project_extra_info'].as_map()['name'].str().to_upper()
	if projname.contains('ARCHIVE') {
		// this is a task linked to a project which is archived, no reason to process
		return Task{}
	}
	mut task := Task{
		description: data_as_map['description'].str()
		id: data_as_map['id'].int()
		project: data_as_map['project'].int()
		user_story: data_as_map['user_story'].int()
		owner: data_as_map['owner'].int()
		due_date_reason: data_as_map['due_date_reason'].str()
		subject: data_as_map['subject'].str()
		is_closed: data_as_map['is_closed'].bool()
		is_blocked: data_as_map['is_blocked'].bool()
		blocked_note: data_as_map['blocked_note'].str()
		ref: data_as_map['ref'].int()
	}
	for tag in data_as_map['tags'].arr() {
		task.tags << tag.str()
	}
	for assign in data_as_map['assigned_to'].arr() {
		if assign.int() != 0 {
			task.assigned_to << assign.int()
		}
	}
	// task.status = data_as_map["status_extra_info"].as_map()["name"].str() // TODO: Use Enum
	task.created_date = parse_time(data_as_map['created_date'].str())
	task.modified_date = parse_time(data_as_map['modified_date'].str())
	task.finished_date = parse_time(data_as_map['finished_date'].str())
	task.due_date = parse_time(data_as_map['due_date'].str())
	task.category = get_category(task)
	task.file_name = generate_file_name(task.subject[0..min(40, task.subject.len)] + '-' +
		task.id.str() + '.md')

	// TODO: Comments later
	// mut conn := connection_get()
	// if conn.settings.comments_task {
	// 	task.comments() ?
	// }
	return task
}

// Get project object for each task
pub fn (task Task) project() Project {
	mut conn := connection_get()
	return *conn.projects[task.project]
}

// Get story object for each task
pub fn (task Task) story() Story {
	mut conn := connection_get()
	if task.user_story != 0 {
		return *conn.stories[task.user_story]
	}
	return Story{}
}

// Get assigned users objects for each task
pub fn (task Task) assigned() []User {
	mut conn := connection_get()
	mut assigned := []User{}
	for i in task.assigned_to {
		assigned << conn.users[i]
	}
	return assigned
}

pub fn (task Task) assigned_as_str() string {
	assignee := task.assigned()
	mut assigned_str := []string{}
	for u in assignee {
		assigned_str << u.username
	}
	return assigned_str.join(', ')
}

// Get owner user object for each task
pub fn (task Task) owner() User {
	mut conn := connection_get()
	return *conn.users[task.owner]
}

// export template per task
pub fn (task Task) as_md(url string) string {
	mut task_md := $tmpl('./templates/task.md')
	task_md = fix_empty_lines(task_md)
	return task_md
}
