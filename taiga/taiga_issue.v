module taiga

struct IssueList {
pub mut:
	issues []Issue
}

struct Issue {
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

pub enum Issueype {
}


fn (mut h TaigaConnection) issues() ?IssueList {
	// reuse single object
	data := h.get_json("issues","",true)?
	mut pl := IssueList{}
	for key,val in data{
		val2 := val.as_map()
		println(key)
		println(val2)
		pl.issues << Issue{
			name: val2["name"].str()
			name_original: val2["name"].str()
		}
		panic("//TODO load issues in obj")
	}
	
	return pl
}

//create issue based on our standards
fn (mut h TaigaConnection) issue_create(name string, description string, issuetype Issueype) ? {
	//TODO 
	h.cache_drop() //to make sure all is consistent
}

