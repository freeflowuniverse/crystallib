module taiga

import despiegk.crystallib.texttools

import json
import x.json2 { raw_decode }
import time { Time }
import math { min }

pub struct Issue {
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
	issue_type             int         [json: 'type']
	created_date           Time        [skip]
	modified_date          Time        [skip]
	finished_date          Time        [skip]
	due_date               Time        [skip]
	due_date_reason        string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
	comments               []Comment
	file_name              string      [skip]
}

struct NewIssue {
pub mut:
	subject string
	project int
}

// get comments in list from issue
pub fn (mut i Issue) get_issue_comments() ?[]Comment {
	i.comments = comments_get('issue', i.id) ?
	return i.comments
}

pub fn issues() ? {
	mut conn := connection_get()
	data := conn.get_json_str('issues', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	for i in data_as_arr {
		temp := (raw_decode(i.str()) or {}).as_map()
		id := temp['id'].int()
		mut issue := issue_get(id) ?
		issue.get_issue_comments() ?
		conn.issue_remember(issue)
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
	response := conn.post_json_str('issues', postdata, true, true) ?
	mut result := issue_decode(response) ?
	conn.issue_remember(result)
	return result
}

pub fn issue_get(id int) ?Issue {
	mut conn := connection_get()
	response := conn.get_json_str('issues/$id', '', true) ?
	mut result := issue_decode(response) ?
	conn.issue_remember(result)
	return result
}

pub fn issue_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('issues', id) ?
	conn.issue_forget(id)
	return response
}

fn issue_decode(data string) ?Issue {
	mut issue := json.decode(Issue, data) ?
	data_as_map := (raw_decode(data) or {}).as_map()
	issue.created_date = parse_time(data_as_map['created_date'].str())
	issue.modified_date = parse_time(data_as_map['modified_date'].str())
	issue.finished_date = parse_time(data_as_map['finished_date'].str())
	issue.due_date = parse_time(data_as_map['due_date'].str())
	file_name := texttools.name_fix(issue.subject[0..min(15, issue.subject.len)])
	issue.file_name =  file_name + '_' + issue.id.str() + '.md'
	issue.project_extra_info.file_name = issue.project_extra_info.slug + '.md'
	return issue
}

pub fn (issue Issue) as_md(url string) string {
	// export template per issue
	mut issue_md := $tmpl('./templates/issue.md')
	issue_md = fix_empty_lines(issue_md)
	return issue_md
}
