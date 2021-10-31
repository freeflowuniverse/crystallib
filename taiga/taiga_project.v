module taiga

import json
import time

struct Project {
pub mut:
	created_date  time.Time	[skip]
	modified_date time.Time  [skip]
	name          string
	description   string
	id            int
	is_private    bool
	members       []int
	tags          []string
	slug          string
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
	mut conn := connection_get()
	return conn.delete('projects', p.id, false)
}


pub fn (mut p Project) stories() ?[]Story {
	mut conn := connection_get()
	//no cache for now, fix later
	data := conn.get_json_str('userstories?project=$p.id', '', false) ?
	return json.decode([]Story, data) or {}
}

//get comments in lis from project
// pub fn (mut p Project) comments() ?[]Comment {
// 	mut conn := connection_get()
// 	//no cache for now, fix later
// 	// data := conn.get_json_str('userstories?project=$p.id', '', false) ?
// 	// return json.decode([]Story, data) or {}

// 	//for further development just fake
// 	//TODO: implement

// 	mut ps := []Comment{}
// 	ps << Project{title:"have no idea",description:"A Description\n\nline1\nline2\n"}
		
// }

//get comments in lis from project
pub fn (mut p Project) issues() ?[]Issue {
	mut conn := connection_get()
	//no cache for now, fix later
	// data := conn.get_json_str('userstories?project=$p.id', '', false) ?
	// return json.decode([]Story, data) or {}
	panic("implement")
}

//return vlang time obj
pub fn (mut p Project) created_date_get() time.Time {
	//panic if time doesn't work
	//make the other one internal, no reason to have the string public
	//do same for all dates
	panic("implement")
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
	mut conn := connection_get()
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
	//TODO: guess this is not finished??? we need to copy the content
	panic("not implemented")
	return new_element
}

// Testing purpose
pub fn get_project(id int) ?Project{
	mut conn := connection_get()
	data := conn.get_json('projects', '$id', true)?	
	mut project := json.decode(Project,data.str())?
	project.created_date = parse_time(data["created_date"].str())
	return project 
}