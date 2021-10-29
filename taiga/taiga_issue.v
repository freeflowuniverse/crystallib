module taiga

import json
// struct IssueList {
// pub mut:
// 	issues []Issue
// }

struct Issue {
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
	severity               int
	priority               int
	issue_type             int             [json: 'type']
	created_date           string
	modified_date          string
	finished_date          string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
}

struct NewIssue {
pub mut:
	subject string
	project int
}

fn (mut h TaigaConnection) issues() ?[]Issue {
	data := h.get_json_str('issues', '', true) ?
	return json.decode([]Issue, data) or {}
}

// create issue based on our standards
pub fn (mut h TaigaConnection) issue_create(subject string, project_id int) ?Issue {
	// TODO
	mut conn :=  get()
	conn.cache_drop()? //to make sure all is consistent, can do this more refined, now we drop all
	issue := NewIssue{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(issue)
	response := h.post_json_str('issues', postdata, true, true) ?
	mut result := json.decode(Issue, response) ?
	return result
}

pub fn (mut h TaigaConnection) issue_get(id int) ?Issue {
	// TODO: Check Cache first (Mohammed Essam), cache should be on higher level
	mut conn :=  get()
	response := conn.get_json_str('issues/$id', "", true) ?
	mut result := json.decode(Issue, response) ?
	return result
}
