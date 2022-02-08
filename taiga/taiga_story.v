module taiga

import despiegk.crystallib.crystaljson
import json
import x.json2
import os
import math { min }

pub fn stories() ? {
	mut conn := connection_get()
	resp := conn.get_json_str('userstories', '', true) ?
	raw_data := json2.raw_decode(resp.replace('\\\\', '')) ?
	blocks := raw_data.arr()
	os.write_file('/tmp/taiga_blocks/stories', '$blocks') ?
	println('[+] Loading $blocks.len stories ...')
	for s in blocks {
		// println('STORY:\n$s')
		mut story := Story{}
		story = story_decode(s.str()) or {
			eprintln(err)
			Story{}
		}
		if story != Story{} && story.project in conn.projects {
			conn.story_remember(story)
		}
	}
}

pub fn story_create(subject string, project_id int) ?Story {
	mut conn := connection_get()
	story := NewStory{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(story)
	response := conn.post_json_str('userstories', postdata, true) ?
	mut result := story_decode(response) ?
	conn.story_remember(result)
	return result
}

pub fn story_get(id int) ?Story {
	mut conn := connection_get()
	response := conn.get_json_str('userstories/$id', '', true) ?
	result := story_decode(response) ?
	conn.story_remember(result)
	return result
}

pub fn story_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('userstories', id) ?
	conn.story_forget(id)
	return response
}

fn story_decode(data string) ?Story {
	data_as_map := crystaljson.json_dict_filter_any(data, false, [], []) ?

	mut story := Story{
		description: data_as_map['description'].str()
		id: data_as_map['id'].int()
		is_private: data_as_map['is_private'].bool()
		project: data_as_map['project'].int()
		owner: data_as_map['owner'].int()
		due_date_reason: data_as_map['due_date_reason'].str()
		subject: data_as_map['subject'].str()
		is_closed: data_as_map['is_closed'].bool()
		is_blocked: data_as_map['is_blocked'].bool()
		blocked_note: data_as_map['blocked_note'].str()
		ref: data_as_map['ref'].int()
	}

	story.created_date = parse_time(data_as_map['created_date'].str())
	story.modified_date = parse_time(data_as_map['modified_date'].str())
	story.finish_date = parse_time(data_as_map['finish_date'].str())
	story.due_date = parse_time(data_as_map['due_date'].str())
	story.category = get_category(story)
	for tag in data_as_map['tags'].arr() {
		story.tags << tag.str()
	}
	for assign in data_as_map['assigned_to'].arr() {
		if assign.int() != 0 {
			story.assigned_to << assign.int()
		}
	}
	// story.status = data_as_map["status_extra_info"]["name"].str() // TODO: Use Enum
	story.file_name = generate_file_name(story.subject[0..min(40, story.subject.len)] + '_' +
		story.id.str() + '.md')

	// TODO: Comments later
	// mut conn := connection_get()
	// if conn.settings.comments_story {
	// 	story.comments() ?
	// }
	return story
}

// get comments in list from story
pub fn (mut s Story) comments() ?[]Comment {
	s.comments = comments_get('userstory', s.id) ?
	return s.comments
}

// get tasks objects for each story
pub fn (story Story) tasks() []&Task {
	mut conn := connection_get()
	mut story_tasks := []&Task{}
	for _, task in conn.tasks {
		mut t_story := task.user_story
		if t_story == story.id {
			story_tasks << task
		}
	}
	return story_tasks
}

// Get project object
pub fn (story Story) project() &Project {
	mut conn := connection_get()
	return conn.project_get(story.project)
}

pub fn (story Story) owner() &User {
	mut conn := connection_get()
	return conn.user_get(story.owner)
}

pub fn (story Story) assigned() []&User {
	mut conn := connection_get()
	mut assigned := []&User{}
	for i in story.assigned_to {
		assigned << conn.user_get(i)
	}
	return assigned
}

pub fn (story Story) assigned_as_str() string {
	assigned := story.assigned()
	mut assigned_str := []string{}
	for u in assigned {
		assigned_str << u.username
	}
	return assigned_str.join(', ')
}

pub fn (story Story) as_md(url string) string {
	owner := story.owner()
	assigned_to := story.assigned_as_str()
	project := story.project()
	tasks := story.tasks()
	mut story_md := $tmpl('./templates/story.md')
	story_md = fix_empty_lines(story_md)
	return story_md
}
