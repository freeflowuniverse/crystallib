module taiga
import json

// struct ProjectList {
// pub mut:
// 	projects []Project
// }

struct Project {
pub mut:
	name string
	description string
	id int
	is_private bool
	members []int
	tags []string
	slug string
	created_date string
	modified_date string
	owner ProjectOwner
}

struct ProjectOwner{
pub mut:
	username string
	id int
	email string
}

pub enum Projectype {
	funnel
	project
	team
}


fn (mut h TaigaConnection) projects() ?[]Project {
	data := h.get_json_str("projects","",true)?
	return json.decode([]Project, data)
}

//create project based on our standards
fn (mut h TaigaConnection) project_create(name string, description string, projtype Projectype) ? {
	//TODO 
	h.cache_drop() //to make sure all is consistent
}

