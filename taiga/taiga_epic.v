module taiga

import json

struct Epic {
pub mut:
	description            string
	id                     int
	is_private             bool
	tags                   []string
	project                int
	project_extra_info     ProjectInfo
	user_story             int
	status                 int
	status_extra_info      StatusInfo
	assigned_to            int
	assigned_to_extra_info UserInfo
	owner                  int
	owner_extra_info       UserInfo
	created_date           string
	modified_date          string
	finished_date          string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	client_requirement     bool
	team_requirement       bool
	ref                    int
	user_stories_counts    UserStoriesCount
	client                 TaigaConnection
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

fn (mut h TaigaConnection) epics() ?[]Epic {
	data := h.get_json_str('epics', '', true) ?
	return json.decode([]Epic, data) or {}
}

fn (mut h TaigaConnection) epic_create(subject string, project_id int) ?Epic {
	// TODO
	// h.cache_drop() //to make sure all is consistent
	epic := NewEpic{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(epic)
	response := h.post_json_str('epics', postdata, true, true) ?
	mut result := json.decode(Epic, response) ?
	result.client = h
	return result
}

fn (mut h TaigaConnection) epic_get(id int) ?Epic {
	// TODO: Check Cache first (Mohammed Essam)
	response := h.get_json_str('epics/$id', "", true) ?
	mut result := json.decode(Epic, response) ?
	result.client = h
	return result
}
