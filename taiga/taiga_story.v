module taiga

import despiegk.crystallib.texttools
import x.json2 { raw_decode }
import json
import time { Time }
import math { min }

pub struct Story {
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
	created_date           Time        [skip]
	modified_date          Time        [skip]
	finish_date            Time        [skip]
	due_date               Time        [skip]
	due_date_reason        string
	subject                string
	is_closed              bool
	is_blocked             bool
	blocked_note           string
	ref                    int
	client_requirement     bool
	team_requirement       bool
	tasks                  []int
	comments               []Comment
	file_name              string      [skip]
}

// get comments in lis from story
pub fn (mut s Story) get_story_comments() ?[]Comment {
	s.comments = comments_get('userstory', s.id) ?
	return s.comments
}

// get tasks objects for each story
pub fn (s Story) get_story_tasks() ?[]Task {
	mut conn := connection_get()
	mut story_tasks := []Task{}
	for _, task in conn.tasks {
		if task.user_story_extra_info.id == s.id {
			story_tasks << task
		}
	}
	return story_tasks
}

struct NewStory {
pub mut:
	subject string
	project int
}

pub fn stories() ? {
	mut conn := connection_get()
	data := conn.get_json_str('userstories', '', true) ?
	data_as_arr := (raw_decode(data) or {}).arr()
	for s in data_as_arr {
		temp := (raw_decode(s.str()) or {}).as_map()
		id := temp['id'].int()
		mut story := story_get(id) ?
		story.get_story_comments() ?
		conn.story_remember(story)
	}
}

pub fn story_create(subject string, project_id int) ?Story {
	mut conn := connection_get()
	story := NewStory{
		subject: subject
		project: project_id
	}
	postdata := json.encode_pretty(story)
	response := conn.post_json_str('userstories', postdata, true, true) ?
	mut result := story_decode(response) ?
	conn.story_remember(result)
	return result
}

pub fn story_get(id int) ?Story {
	mut conn := connection_get()
	response := conn.get_json_str('userstories/$id', '', true) ?
	result := story_decode(response) ?
	conn.story_remember(result)
	return result
}

pub fn story_delete(id int) ?bool {
	mut conn := connection_get()
	response := conn.delete('userstories', id) ?
	conn.story_forget(id)
	return response
}

fn story_decode(data string) ?Story {
	data_as_map := (raw_decode(data) or {}).as_map()
	mut story := json.decode(Story, data) ?
	story.created_date = parse_time(data_as_map['created_date'].str())
	story.modified_date = parse_time(data_as_map['modified_date'].str())
	story.finish_date = parse_time(data_as_map['finish_date'].str())
	story.due_date = parse_time(data_as_map['due_date'].str())
	story.file_name = texttools.name_fix_no_filesep(story.subject[0..min(15, story.subject.len)] +
		'_' + story.id.str()) + '.md'
	story.project_extra_info.file_name =
		texttools.name_fix_no_filesep(story.project_extra_info.slug) + '.md'
	return story
}

pub fn (story Story) as_md(url string) string {
	tasks := story.get_story_tasks() or {
		panic("Can't get tasks for story $story.id with error: $err")
	} // For template rendering
	// export template per story
	mut story_md := $tmpl('./templates/story.md')
	story_md = fix_empty_lines(story_md)
	return story_md
}
