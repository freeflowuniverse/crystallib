module taiga

import json
import time

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

//return vlang time obj
pub fn (mut e Epic) created_date_get() time.Time {
	//panic if time doesn't work
	//make the other one internal, no reason to have the string public
	//do same for all dates
	panic("implement")
}



fn (mut h TaigaConnection) epics() ?[]Epic {
	data := h.get_json_str('epics', '', true) ?
	return json.decode([]Epic, data) or {}
}

fn (mut h TaigaConnection) epic_create(subject string, project_id int) ?Epic {
	// TODO
	mut conn :=  connection_get()
	conn.cache_drop()?
	epic := NewEpic{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(epic)
	response := h.post_json_str('epics', postdata, true, true) ?
	mut result := json.decode(Epic, response) ?
	return result
}

fn (mut h TaigaConnection) epic_get(id int) ?Epic {
	// TODO: Check Cache first (Mohammed Essam)
	mut conn :=  connection_get()
	response := conn.get_json_str('epics/$id', "", true) ?
	mut result := json.decode(Epic, response) ?
	return result
}
