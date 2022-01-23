module taiga
import despiegk.crystallib.crystaljson
import despiegk.crystallib.texttools
import json
// import x.json2 { raw_decode }
import time { Time }
import math { min }


enum IssueSeverity {
	unknown
	wishlist
	minor
	normal
	important
	critical
}

enum IssuePriority {
	unknown
	low
	normal
	high
}


enum IssueStatus {
	unknown
	new
	inprogress
	verification //is called ready for test in taiga
	closed
	needsinfo
	rejected
	postponed
}

enum IssueType {
	unknown
	bug
	question
	enhancement	
}

//TODO: go in circles tool, is the types not well set on the project, change them yourself !!!


pub struct Issue {
pub mut:
	description            string
	id                     int
	is_private             bool
	tags                   []string
	project                int						//if project not found use 0
	status                 IssueStatus				//TODO: when decoding , be defensive, try to find what was meant in taiga
	assigned_to            int
	owner                  int						//is this only assigned to one person? TODO
	severity               IssueSeverity			//TODO: we need to create proper vlang enums, if not right set on source, use unknown
	priority               IssuePriority			//TODO: we need to create proper vlang enums
	issue_type             IssueType        		//TODO: 
	created_date           Time 
	modified_date          Time 
	finished_date          Time 
	due_date               Time 
	due_date_reason        string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int						//TODO: is that the id of taiga, maybe we should use this on our mem db, and make it a map
	comments               []Comment
	file_name              string					//need to make sure we always have ascii and namefix done
}

struct NewIssue {
pub mut:
	subject string
	project int
}

// get comments in list from issue
pub fn (mut i Issue) get_comments() ?[]Comment {
	i.comments = comments_get('issue', i.id) ?
	return i.comments
}

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

	data_as_map := crystaljson.json_dict_any(data,false,[],[])?

	mut issue := Issue{
		//TODO:
	}

	issue.created_date = parse_time(data_as_map['created_date'].str())
	issue.modified_date = parse_time(data_as_map['modified_date'].str())
	issue.finished_date = parse_time(data_as_map['finished_date'].str())
	issue.due_date = parse_time(data_as_map['due_date'].str())
	issue.file_name = texttools.name_clean(issue.subject[0..min(40, issue.subject.len)] +
		'_' + issue.id.str()) + '.md'
	issue.file_name = texttools.ascii_clean(issue.file_name)
	// issue.project_extra_info.file_name =
	// 	texttools.name_clean(issue.project_extra_info.slug) + '.md'
	mut conn := connection_get()
	if conn.settings.comments_issue{
		issue.get_comments()?
	}		
	return issue
}

pub fn (issue Issue) project() ?Project {
	//TODO:
	return Project{}
}

pub fn (issue Issue) assigned() ?[]User {
	//TODO:
	return []User{}
}



pub fn (issue Issue) as_md(url string) ?string {
	// export template per issue
	project := issue.project()?
	mut issue_md := $tmpl('./templates/issue.md')
	issue_md = fix_empty_lines(issue_md)
	return issue_md
}
