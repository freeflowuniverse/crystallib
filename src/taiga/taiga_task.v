module taiga
import json

struct Task {
pub mut:
	description string
	id int
	is_private bool
	tags []string
	project int
	project_extra_info ProjectInfo
	user_story int
	user_story_extra_info UserStoryInfo
	status int
	status_extra_info StatusInfo
	assigned_to int
	assigned_to_extra_info UserInfo
	owner int
	owner_extra_info UserInfo
	created_date string
	modified_date string
	finished_date string
	subject string
	is_closed bool
	is_blocked bool
	blocked_note string
	ref int
}

struct NewTask {
pub mut:
	subject string
	project int
}


fn (mut h TaigaConnection) tasks() ?[]Task {
	data := h.get_json_str("tasks","",true)?
	return json.decode([]Task, data)
}

fn (mut h TaigaConnection) task_create(subject string, project_id int) ? {
	//TODO 
	// h.cache_drop() //to make sure all is consistent
	task := NewTask{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(task)
	response := h.post_json("tasks",postdata, true, true)?
}
