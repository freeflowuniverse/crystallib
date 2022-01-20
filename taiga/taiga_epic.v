module taiga

import despiegk.crystallib.texttools
import x.json2 { raw_decode }
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
	project_extra_info     ProjectInfo
	user_story             int
	user_story_extra_info  StoryInfo
	status                 int
	status_extra_info      StatusInfo
	assigned_to            int
	assigned_to_extra_info UserInfo
	owner                  int
	owner_extra_info       UserInfo
	created_date           Time             [skip]
	modified_date          Time             [skip]
	finished_date          Time             [skip]
	due_date               Time             [skip]
	due_date_reason        string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	client_requirement     bool
	team_requirement       bool
	ref                    int
	user_stories_counts    UserStoriesCount
	file_name              string           [skip]
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
	data := conn.get_json_str('epics', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	for e in data_as_arr {
		temp := (raw_decode(e.str()) or {}).as_map()
		id := temp['id'].int()
		epic := epic_get(id) ?
		conn.epic_remember(epic)
	}
}

pub fn epic_create(subject string, project_id int) ?Epic {
	mut conn := connection_get()
	epic := NewEpic{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(epic)
	response := conn.post_json_str('epics', postdata, true, true) ?
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
	mut epic := json.decode(Epic, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	epic.created_date = parse_time(data_as_map['created_date'].str())
	epic.modified_date = parse_time(data_as_map['modified_date'].str())
	epic.finished_date = parse_time(data_as_map['modified_date'].str())
	epic.due_date = parse_time(data_as_map['due_date'].str())
	epic.file_name = texttools.name_fix_no_filesep(epic.subject[0..min(15, epic.subject.len)] +
		'-' + epic.id.str()) + '.md'
	return epic
}
