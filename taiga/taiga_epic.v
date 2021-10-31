module taiga

import x.json2
import json
import time {Time}

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
	created_date           Time [skip]
	modified_date          Time [skip]
	finished_date          Time [skip]
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

// //return vlang time obj
// pub fn (mut e Epic) created_date_get() time.Time {
// 	//panic if time doesn't work
// 	//make the other one internal, no reason to have the string public
// 	//do same for all dates
// 	panic("implement")
// }



pub fn epics() ?[]Epic {
	mut conn := connection_get()
	data := conn.get_json_str('epics', '', true) ?
	mut epics := []Epic{} // TODO: Can be removed
	data_as_arr := (json2.raw_decode(data) or {}).arr()
	for e in data_as_arr {
		epic := epic_decode(e.str()) ?
		epics << epic
		epic_remember(epic)
	}
	return epics
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

fn epic_decode(data string) ?Epic{
	mut epic := json.decode(Epic, data) ?
	data_as_map := (json2.raw_decode(data) or {}).as_map()
	epic.created_date = parse_time(data_as_map["created_date"].str())
	epic.modified_date = parse_time(data_as_map["modified_date"].str())
	epic.finished_date = parse_time(data_as_map["modified_date"].str())
	return epic
}
