module taiga

import json

struct UserStory {
pub mut:
	description            string
	id                     int
	is_private             bool
	tags                   []string
	project                int
	project_extra_info     ProjectInfo
	status                 int
	status_extra_info      StatusInfo
	assigned_to            int
	assigned_to_extra_info UserInfo
	owner                  int
	owner_extra_info       UserInfo
	created_date           string
	modified_date          string
	finish_date            string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
	client_requirement     bool
	team_requirement       bool
	tasks                  []Task
	client                 TaigaConnection
}

struct NewUserStory {
pub mut:
	subject string
	project int
}

fn (mut h TaigaConnection) userstories() ?[]UserStory {
	data := h.get_json_str('userstories', '', true) ?
	return json.decode([]UserStory, data) or {}
}

fn (mut h TaigaConnection) userstory_create(subject string, project_id int) ?UserStory {
	// TODO
	// h.cache_drop() //to make sure all is consistent
	userstory := NewUserStory{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(userstory)
	response := h.post_json_str('userstories', postdata, true, true) ?
	mut result := json.decode(UserStory, response) ?
	result.client = h
	return result
}

fn (mut h TaigaConnection) userstory_get(id int) ?UserStory {
	// TODO: Check Cache first (Mohammed Essam)
	response := h.get_json_str('userstories/$id', "", true) ?
	mut result := json.decode(UserStory, response) ?
	result.client = h
	return result
}
