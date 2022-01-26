module taiga

import despiegk.crystallib.crystaljson
import despiegk.crystallib.texttools
import json
import math { min }

// List all issues ( One request only )
pub fn issues() ? {
	mut conn := connection_get()
	blocks := conn.get_json_list('issues', '', true) ?
	println('[+] Loading $blocks.len issues ...')
	for i in blocks {
		mut issue := Issue{}
		issue = issue_decode(i.str()) or {
			eprintln(err)
			Issue{}
		}
		if issue != Issue{} {
			conn.issue_remember(issue)
		}
	}
}

// create issue based on our standards
pub fn issue_create(subject string, project_id int) ?Issue {
	mut conn := connection_get()
	issue := NewIssue{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(issue)
	response := conn.post_json_str('issues', postdata, true) ?
	mut result := issue_decode(response) ?
	conn.issue_remember(result)
	return result
}

// Get issue details using api
pub fn issue_get(id int) ?Issue {
	mut conn := connection_get()
	response := conn.get_json_str('issues/$id', '', true) ?
	mut result := issue_decode(response) ?
	conn.issue_remember(result)
	return result
}

// Delete issue using api, and forget it from cache and singleton object
pub fn issue_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('issues', id) ?
	conn.issue_forget(id)
	return response
}

// Decode issue to get clean object from raw data
fn issue_decode(data string) ?Issue {
	data_as_map := crystaljson.json_dict_any(data, false, [], []) ?
	mut issue := Issue{
		description: data_as_map['description'].str()
		id: data_as_map['id'].int()
		is_private: data_as_map['is_private'].bool()
		project: data_as_map['project'].int()
		owner: data_as_map['owner'].int()
		due_date_reason: data_as_map['due_date_reason'].str()
		subject: data_as_map['subject'].str()
		is_closed: data_as_map['is_closed'].bool()
		is_blocked: data_as_map['is_blocked'].bool()
		blocked_note: data_as_map['blocked_note'].str()
		ref: data_as_map['ref'].int()
	}
	for tag in data_as_map['tags'].arr() {
		issue.tags << tag.str()
	}
	for assign in data_as_map['assigned_to'].arr() {
		if assign.int() != 0 {
			issue.assigned_to << assign.int()
		}
	}
	// issue.status = data_as_map["status_extra_info"]["name"].str() // TODO: Use Enum
	issue.created_date = parse_time(data_as_map['created_date'].str())
	issue.modified_date = parse_time(data_as_map['modified_date'].str())
	issue.finished_date = parse_time(data_as_map['finished_date'].str())
	issue.due_date = parse_time(data_as_map['due_date'].str())
	issue.file_name = generate_file_name(issue.subject[0..min(40, issue.subject.len)] + '_' +
		issue.id.str() + '.md')
	issue.category = get_category(issue)

	// TODO: Comments Later
	// mut conn := connection_get()
	// if conn.settings.comments_issue {
	// 	issue.comments() ?
	// }
	return issue
}

// get comments in list from issue
pub fn (mut issue Issue) comments() ?[]Comment {
	issue.comments = comments_get('issue', issue.id) ?
	return issue.comments
}

// Get project object for each issue
pub fn (issue Issue) project() Project {
	mut conn := connection_get()
	project := conn.projects[issue.project]
	return *project
}

// Get assigned users objects for each issue
pub fn (issue Issue) assigned() []User {
	mut conn := connection_get()
	mut assigned_users := []User{}
	for i in issue.assigned_to {
		assigned_users << conn.users[i]
	}
	return assigned_users
}

pub fn (issue Issue) assigned_as_str() string {
	assigned_users := issue.assigned()
	mut assigned_str := []string{}
	for u in assigned_users {
		assigned_str << u.username
	}
	return assigned_str.join(', ')
}

// Get owner user object for each issue
pub fn (issue Issue) owner() User {
	mut conn := connection_get()
	mut owner := conn.users[issue.owner]
	return *owner
}

pub fn (issue Issue) as_md(url string) string {
	mut issue_md := $tmpl('./templates/issue.md')
	issue_md = fix_empty_lines(issue_md)
	return issue_md
}
