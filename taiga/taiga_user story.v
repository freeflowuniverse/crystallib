module taiga
import json

struct UserStory {
pub mut:
	description string
	id int
	is_private bool
	tags []string
	project int
	status int
	assigned_to int
	owner int
	created_date string
	modified_date string
	finish_date string
	subject string
	is_closed bool
	is_blocked bool
	blocked_note string
	ref int
	client_requirement bool
	team_requirement bool
	tasks []Task
}

fn (mut h TaigaConnection) userstories() ?[]UserStory {
	data := h.get_json_str("userstories","",true)?
	return json.decode([]UserStory, data)
}
