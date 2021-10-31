module taiga

import x.json2 {raw_decode}
import json
import time {Time}

struct Task {
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
	created_date           Time [skip]
	modified_date          Time [skip]
	finished_date          Time [skip]
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
}

struct NewTask {
pub mut:
	subject string
	project int
}

fn tasks() ?[]Task {
	mut conn := connection_get()
	data := conn.get_json_str('tasks', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	mut tasks := []Task{}
	for t in data_as_arr {
		task := task_decode(t.str()) ?
		task_remember(task)
		tasks << task
	}
	return tasks
}

//get comments in lis from task
pub fn (mut t Task) comments() ?[]Comment {
	mut conn := connection_get()
	//no cache for now, fix later
	// data := conn.get_json_str('userstories?project=$p.id', '', false) ?
	// return json.decode([]task, data) or {}
	panic("implement")
}

//return 
pub fn (mut t Task) created_date_get() time.Time {
	//panic if time doesn't work
	//make the other one internal, no reason to have the string public
	//do same for all dates
	panic("implement")
}



pub fn (mut h TaigaConnection) task_create(subject string, project_id int) ?Task {
	// TODO
	h.cache_drop()? //to make sure all is consistent, too harsh need to be improved
	task := NewTask{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(task)
	response := h.post_json_str('tasks', postdata, true, true) ?
	mut result :=  json.decode(Task, response) ?
	return result
}

pub fn (mut h TaigaConnection) task_get(id int) ?Task {
	// TODO: Check Cache first (Mohammed Essam)
	response := h.get_json_str('tasks/$id', "", true) ?
	mut result := json.decode(Task, response) ?
	return result
}

fn task_decode(data string) ? Task{
	mut task := json.decode(Task, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	task.created_date = parse_time(data_as_map["created_date"].str())
	task.modified_date = parse_time(data_as_map["modified_date"].str())
	task.finished_date = parse_time(data_as_map["finished_date"].str())
	return task
}
