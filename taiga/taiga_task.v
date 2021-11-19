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
	comments               []Comment
}

struct NewTask {
pub mut:
	subject string
	project int
}

pub fn tasks() ? {
	mut conn := connection_get()
	data := conn.get_json_str('tasks', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	for t in data_as_arr {
		temp := (raw_decode(t.str()) or {}).as_map()
		id := temp["id"].int()
		mut task := task_get(id) ?
		task.get_task_comments() ?
		conn.task_remember(task)
	}
}

//get comments in lis from task
pub fn (mut t Task) get_task_comments() ?[]Comment {
	t.comments = comments_get("task", t.id) ?
	return t.comments

}



pub fn task_create(subject string, project_id int) ?Task {
	mut conn := connection_get()
	task := NewTask{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(task)
	response := conn.post_json_str('tasks', postdata, true, true) ?
	mut result :=  task_decode(response) ?
	conn.task_remember(result)
	return result
}

pub fn task_get(id int) ?Task {
	mut conn := connection_get()
	response := conn.get_json_str('tasks/$id', "", true) ?
	mut result := task_decode(response) ?
	conn.task_remember(result)
	return result
}
pub fn task_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('tasks', id) ?
	conn.task_forget(id)
	return response
}

fn task_decode(data string) ? Task{
	mut task := json.decode(Task, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	task.created_date = parse_time(data_as_map["created_date"].str())
	task.modified_date = parse_time(data_as_map["modified_date"].str())
	task.finished_date = parse_time(data_as_map["finished_date"].str())
	return task
}
