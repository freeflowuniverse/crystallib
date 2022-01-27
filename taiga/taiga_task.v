module taiga

import x.json2 { raw_decode }
import math { min }
import json

pub fn tasks() ? {
	mut conn := connection_get()
	resp := conn.get_json_str('tasks', '', true) ?
	raw_data := raw_decode(resp.replace('\\\\', '')) ?
	blocks := raw_data.arr()
	println('[+] Loading $blocks.len tasks ...')
	for t in blocks {
		mut task := Task{}
		task = task_decode(t.str()) or {
			eprintln(err)
			Task{}
		}
		// Add only tasks that belong to known project (Not Archived one)
		if task != Task{} && task.project in conn.projects {
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
	data_raw := raw_decode(data) ?
	data_as_map := data_raw.as_map()
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
	task.set_status()
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

fn (task Task) set_status(st string) {
	status := st.to_lower()
	if status.contains('new') {
		task.status = TaskStatus.new
	} else if status.contains('accepted') {
		task.status = TaskStatus.accepted
	} else if status.contains('inprogress') {
		task.status = TaskStatus.inprogress
	} else if status.contains('verification') {
		task.status = TaskStatus.verification
	} else if status.contains('done') {
		task.status = TaskStatus.done
	} else {
		task.status = TaskStatus.unknown
	}
}

// Get project object for each task
pub fn (task Task) project() &Project {
	mut conn := connection_get()
	return conn.project_get(task.project)
}

// Get story object for each task
pub fn (task Task) story() &Story {
	mut conn := connection_get()
	if task.user_story != 0 {
		return conn.story_get(task.user_story)
	}
	return &Story{}
}

// Get assigned users objects for each task
pub fn (task Task) assigned() []&User {
	mut conn := connection_get()
	mut assigned := []&User{}
	for i in task.assigned_to {
		assigned << conn.user_get(i)
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
pub fn (task Task) owner() &User {
	mut conn := connection_get()
	return conn.user_get(task.owner)
}

// export template per task
pub fn (task Task) as_md(url string) string {
	owner := task.owner()
	assigned_to := task.assigned_as_str()
	story := task.story()
	project := task.project()
	mut task_md := $tmpl('./templates/task.md')
	task_md = fix_empty_lines(task_md)
	return task_md
}
