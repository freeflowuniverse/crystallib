module taiga

import texttools
import json

struct Project {
pub mut:
	name          string
	description   string
	id            int
	is_private    bool
	members       []int
	tags          []string
	slug          string
	created_date  string
	modified_date string
	owner         UserInfo
	projtype      Projectype
}

pub enum Projectype {
	funnel
	project
	team
}

pub enum TaigaElementTypes{
	story
	issue
	task
	epic
}

pub fn (mut p Project) delete() ?bool {
	mut conn := get()
	return conn.delete('projects', p.id, false)
}


pub fn (mut p Project) stories() ?[]Story {
	mut conn := get()
	data := conn.get_json_str('stories', '', true) ?
	return json.decode([]Story, data) or {}
}


pub fn (mut p Project) copy (element_type TaigaElementTypes, element_id int, to_project_id int) ?TaigaElement {
	/*
	Copy story, issue, task and epic from project to other one.
	Inputs:
		element_type: enum --> story, issue, task and epic
		element_id: id of the element we want to copy
		to_project_id: id of the destination project
	Output
		new_element: return the new element casted as TaigaElement Type
	*/
	mut conn := get()
	mut new_element := TaigaElement(Issue{}) // Initialize with any empty element type
	match element_type{
		.story {
			//Get element
			element := conn.story_get(element_id) ?
			// Create new element in the distination project
			new_element = conn.story_create(element.subject, to_project_id) ?
		}
		.issue {
			element := conn.issue_get(element_id) ?
			new_element = conn.issue_create(element.subject, to_project_id) ?
		}
		.task {
			element := conn.task_get(element_id) ?
			new_element = conn.task_create(element.subject, to_project_id) ?
		}
		.epic {
			element := conn.epic_get(element_id) ?
			new_element = conn.epic_create(element.subject, to_project_id) ?
		}
	}
	return new_element
}
