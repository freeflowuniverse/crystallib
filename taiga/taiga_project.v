module taiga

struct ProjectList {
pub mut:
	projects []Project
}

struct Project {
pub mut:
	name string  //normalized name
	name_original string
	description string
	id int
	uuid string
	is_private bool
	// members[]
	tags []string
	slug string	
}

pub enum Projectype {
	funnel
	project
	team
}


fn (mut h TaigaConnection) projects() ?ProjectList {
	// reuse single object
	data := h.get_json("projects","",true)?
	mut pl := ProjectList{}
	for key,val in data{
		val2 := val.as_map()
		println(key)
		println(val2)
		pl.projects << Project{
			name: val2["name"].str()
			name_original: val2["name"].str()
		}
		panic("//TODO load projects in obj")
	}
	
	return pl
}

//create project based on our standards
fn (mut h TaigaConnection) project_create(name string, description string, projtype Projectype) ? {
	//TODO 
	h.cache_drop() //to make sure all is consistent
}

