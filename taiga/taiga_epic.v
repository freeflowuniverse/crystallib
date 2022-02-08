module taiga

// Epics will be implemented later
import despiegk.crystallib.crystaljson
import despiegk.crystallib.texttools
import json
import x.json2
import os
import time
import math { min }

pub fn epics() ? {
	mut conn := connection_get()
	resp := conn.get_json_str('epics', '', true) ?
	raw_data := json2.raw_decode(resp.replace('\\\\', '')) ?
	blocks := raw_data.arr()
	os.write_file('/tmp/taiga_blocks/epics', '$blocks') ?
	println('[+] Loading $blocks.len epics ...')
	for e in blocks {
		mut epic := Epic{}
		epic = epic_decode(e.str()) or {
			eprintln(err)
			Epic{}
		}
		if epic != Epic{} && epic.project in conn.projects {
			conn.epic_remember(epic)
		}
	}
}

pub fn epic_create(subject string, project_id int) ?Epic {
	mut conn := connection_get()
	epic := NewEpic{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(epic)
	response := conn.post_json_str('epics', postdata, true) ?
	mut result := epic_decode(response) ?
	conn.epic_remember(result)
	return result
}

fn epic_get(id int) ?Epic {
	mut conn := connection_get()
	response := conn.get_json_str('epics/$id', '', true) ?
	mut result := epic_decode(response) ?
	conn.epic_remember(result)
	return result
}

pub fn epic_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('epics', id) ?
	conn.epic_forget(id)
	return response
}

fn epic_decode(data string) ?Epic {
	data_as_map := crystaljson.json_dict_filter_any(data, false, [], []) ?

	mut epic := Epic{
		description: data_as_map['description.'].str()
	}
	// TODO: use raw json data_as_map feature to link to object, do all the others
	// TODO: when a user, project, ... find it in the memdb to get right id

	epic.created_date = parse_time(data_as_map['created_date'].str())
	epic.modified_date = parse_time(data_as_map['modified_date'].str())
	epic.finished_date = parse_time(data_as_map['modified_date'].str())
	epic.due_date = parse_time(data_as_map['due_date'].str())
	epic.file_name = generate_file_name(epic.subject[0..min(40, epic.subject.len)] + '-' +
		epic.id.str() + '.md')
	return epic
}

// Get project object for each epic
pub fn (epic Epic) project() ?Project {
	return Project{}
}

// Get assigned users objects for each epic
pub fn (epic Epic) assigned() ?[]User {
	// TODO:
	return []User{}
}

// Get owner user object for each epic
pub fn (epic Epic) owner() ?User {
	// TODO:
	return User{}
}

// Get owner user object for each epic
pub fn (epic Epic) user_story() ?User {
	// TODO:
	return User{}
}
