module taiga
import despiegk.crystallib.crystaljson
import despiegk.crystallib.texttools
// import x.json2 { raw_decode }
import json
import time { Time }
import math { min }

pub struct Epic {
pub mut:
	description            string
	id                     int
	is_private             bool
	tags                   []string
	project                int
	user_story             int
	status                 int
	assigned_to            int
	owner                  int
	created_date           Time 
	modified_date          Time
	finished_date          Time
	due_date               Time
	due_date_reason        string
	subject                string
	is_closed              bool
	is_blocked             bool
	ref                    int
	user_stories_counts    UserStoriesCount
	file_name              string
}

struct UserStoriesCount {
	total    int
	progress int
}

struct NewEpic {
pub mut:
	subject string
	project int
}

pub fn epics() ? {
	mut conn := connection_get()
	blocks := conn.get_json_list('epics', '', true) ?
	println('[+] Loading $blocks.len epics ...')
	for e in blocks {
		mut epic := Epic{}
		epic = epic_decode(e.str()) or {
			eprintln(err)
			Epic{}
		}
		if epic != Epic{} {
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

	data_as_map := crystaljson.json_dict_any(data,false,[],[])?

	mut epic := Epic{
		description : data_as_map["description."].str()
	}
	//TODO: use raw json data_as_map feature to link to object, do all the others
	//TODO: when a user, project, ... find it in the memdb to get right id

	epic.created_date = parse_time(data_as_map['created_date'].str())
	epic.modified_date = parse_time(data_as_map['modified_date'].str())
	epic.finished_date = parse_time(data_as_map['modified_date'].str())
	epic.due_date = parse_time(data_as_map['due_date'].str())
	epic.file_name = texttools.name_clean(epic.subject[0..min(40, epic.subject.len)] +
		'-' + epic.id.str()) + '.md'
	epic.file_name = texttools.ascii_clean(epic.file_name)
	return epic
}
