module taiga
import json

struct Task {
pub mut:
	description string
	id int
	is_private bool
	tags []string
	project int
	user_story int
	status int
	assigned_to int
	owner int
	created_date string
	modified_date string
	finished_date string
	subject string
	is_closed bool
	is_blocked bool
	blocked_note string
	ref int
}


fn (mut h TaigaConnection) tasks() ?[]Task {
	data := h.get_json_str("tasks","",true)?
	return json.decode([]Task, data)
}

