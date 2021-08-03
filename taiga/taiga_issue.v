module taiga
import json
// struct IssueList {
// pub mut:
// 	issues []Issue
// }

struct Issue {
pub mut:
	description string
	id int
	is_private bool
	tags []string
	project int
	status int
	assigned_to int
	owner int
	severity int
	priority int
	issue_type int [json: "type"]
	created_date string
	modified_date string
	finished_date string
	subject string
	is_closed bool
	is_blocked bool
	blocked_note string
	ref int
}

pub enum Issueype {
	other
}


fn (mut h TaigaConnection) issues() ?[]Issue {
	data := h.get_json_str("issues","",true)?
	return json.decode([]Issue, data)
}

//create issue based on our standards
fn (mut h TaigaConnection) issue_create(name string, description string, issuetype Issueype) ? {
	//TODO 
	h.cache_drop() //to make sure all is consistent
}

