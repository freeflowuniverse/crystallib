module taiga
import texttools
import json

// struct ProjectList {
// pub mut:
// 	projects []Project
// }

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
}

pub enum Projectype {
	funnel
	project
	team
}

struct NewProject {
pub mut:
	name                 string
	description          string
	is_issues_activated  bool
	is_private           bool
	is_backlog_activated bool
	is_kanban_activated  bool
	is_wiki_activated    bool
}

struct NewProjectConfig {
pub mut:
	severities      []string
	priorities      []string
	issues_types    []string
	issues_statuses []string
	story_statuses  []string
	task_statuses   []string
	item_statuses   []string
	custom_fields   []string
}

fn (mut h TaigaConnection) projects() ?[]Project {
	data := h.get_json_str('projects', '', true) ?
	return json.decode([]Project, data) or {}
}

//get the project
fn (mut h TaigaConnection) project_get(name string) ?Project  {
	//because we cache we can walk over it
	name2 := texttools.name_fix(name)
	for proj in h.projects(){
		if proj.name == name2{
			return proj
		}
	}
}


//check if project exists with certain name
fn (mut h TaigaConnection) project_exists(name string) bool  {
	h.project_get or {return false}
	return true
}

// create project based on predefined standards
// return project id
fn (mut h TaigaConnection) project_create(name string, description string, projtype Projectype) ?int  {
	// TODO
	// h.cache_drop() //to make sure all is consistent
	mut proj := NewProject{
		description: description
		is_issues_activated: true
		is_private: false
	}
	mut proj_config := NewProjectConfig{}

	match projtype {
		.funnel {
			proj.name = texttools.name_fix('FUNNEL_' + name2)
			proj.is_backlog_activated = false
			proj.is_kanban_activated = true
			proj.is_wiki_activated = true

			proj_config.severities << ['unknown', 'low', '25%', '50%', '75%', '90%']
			proj_config.priorities << ['Low', 'Normal', 'High']
			proj_config.issues_types << 'opportunity'
			proj_config.issues_statuses << ['New', 'Interested', 'Deal', 'Blocked', 'NeedInfo',
				'Lost', 'Postponed', 'Won']
			proj_config.story_statuses << ['New', 'Proposal', 'Contract', 'Blocked', 'NeedInfo',
				'Closed',
			]
			proj_config.task_statuses << ['New', 'In progress', 'Verification', 'Needs info',
				'Closed',
			]
			proj_config.custom_fields << ['bookings', 'commission']
		}
		.project {
			proj.name = texttools.name_fix('PROJECT_' + name2()
			proj.is_backlog_activated = false
			proj.is_kanban_activated = true
			proj.is_wiki_activated = false

			proj_config.issues_types << ['Bug', 'Question', 'Enhancement']
			proj_config.severities << ['Wishlist', 'Minor', 'Normal', 'Important', 'Critical']
			proj_config.story_statuses << ['New', 'to-start', 'in-progress', 'Blocked', 'Implemented',
				'Verified', 'Archived']
			proj_config.item_statuses << ['New', 'to-start', 'in-progress', 'Blocked', 'Done']
			proj_config.issues_statuses << ['New', 'to-start', 'in-progress', 'Blocked',
				'Implemented', 'Closed', 'Rejected', 'Postponed', 'Archived']
		}
		.team {
			proj.name = texttools.name_fix('TEAM_' + name2)
			proj.is_backlog_activated = true
			proj.is_kanban_activated = false
			proj.is_wiki_activated = true

			proj_config.issues_types << ['Bug', 'Question', 'Enhancement']
			proj_config.severities << ['Wishlist', 'Minor', 'Normal', 'Important', 'Critical']
			proj_config.story_statuses << ['New', 'to-start', 'in-progress', 'Blocked', 'Implemented',
				'Verified', 'Archived']
			proj_config.item_statuses << ['New', 'to-start', 'in-progress', 'Blocked', 'Done']
			proj_config.issues_statuses << ['New', 'to-start', 'in-progress', 'Blocked',
				'Implemented', 'Closed', 'Rejected', 'Postponed', 'Archived']
		}
	}
	postdata := json.encode_pretty(proj)
	response := h.post_json('projects', postdata, true, true) ?
	return response["id"]
}
