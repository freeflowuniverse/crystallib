module taiga
import json

struct Epic {
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
	client_requirement bool
	team_requirement bool
	ref int
	user_stories_counts UserStoriesCount
}

struct UserStoriesCount{
	total int
	progress int
}

fn (mut h TaigaConnection) epics() ?[]Epic {
	data := h.get_json_str("epics","",true)?
	return json.decode([]Epic, data)
}

