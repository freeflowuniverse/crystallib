module taiga

import x.json2 {raw_decode}
import json
import time {Time}

struct Story {
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
	created_date           Time [skip]
	modified_date          Time [skip]
	finish_date            Time [skip]
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
	client_requirement     bool
	team_requirement       bool
	tasks                  []Task
}

//get comments in lis from story
pub fn (mut s Story) comments() ?[]Comment {
	mut conn := connection_get()
	//no cache for now, fix later
	// data := conn.get_json_str('userstories?project=$p.id', '', false) ?
	// return json.decode([]Story, data) or {}
	panic("implement")
}

//get comments in lis from story
pub fn (mut s Story) tasks() ?[]Task {
	mut conn := connection_get()
	//no cache for now, fix later
	// data := conn.get_json_str('userstories?project=$p.id', '', false) ?
	// return json.decode([]Story, data) or {}
	panic("implement")
}

//return vlang time obj
pub fn (mut s Story) created_date_get() time.Time {
	//panic if time doesn't work
	//make the other one internal, no reason to have the string public
	//do same for all dates
	panic("implement")
}


struct NewStory {
pub mut:
	subject string
	project int
}

pub fn stories() ?[]Story {
	mut conn := connection_get()
	data := conn.get_json_str('userstories', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	mut stories := []Story{}
	for s in data_as_arr {
		story := story_decode(s.str()) ?
		story_remember(story)
		stories << story
	}
	return stories
}

pub fn (mut h TaigaConnection) story_create(subject string, project_id int) ?Story {
	h.cache_drop()? //to make sure all is consistent
	story := NewStory{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(story)
	response := h.post_json_str('userstories', postdata, true, true) ?
	mut result := json.decode(Story, response) ?
	return result
}

pub fn (mut h TaigaConnection) story_get(id int) ?Story {
	// TODO: Check Cache first (Mohammed Essam)
	response := h.get_json_str('userstories/$id', "", true) ?
	mut result := json.decode(Story, response) ?
	return result
}

fn story_decode(data string) ? Story{
	mut story := json.decode(Story, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	story.created_date = parse_time(data_as_map["created_date"].str())
	story.modified_date = parse_time(data_as_map["modified_date"].str())
	story.finish_date = parse_time(data_as_map["finish_date"].str())
	return story
}
