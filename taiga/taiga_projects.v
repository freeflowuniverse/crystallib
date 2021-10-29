module taiga

import texttools
import json

type TaigaElement = Story | Issue | Task | Epic
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

pub fn (mut h TaigaConnection) projects() ?[]Project {
	// List all Projects
	mut conn := connection_get()
	data := conn.get_json_str('projects', '', true) ?	
	mut projects := json.decode([]Project, data) or {}
	//need to do this for all
	for proj in projects{
		h.project_remember(proj)
	}
	return projects
}

// get the project
pub fn (mut h TaigaConnection) project_get_by_name(name string) ?Project {
	// Get project by name
	// because we cache we can walk over it
	mut conn := connection_get()
	name2 := texttools.name_fix(name)
	mut all_projects := conn.projects() ?
	for mut proj in all_projects {
		if proj.name == name2 {
			// proj.client = h
			return proj
		}
	}
	return error('cannot find project with name: $name')
}

// check if project exists with certain name
pub fn (mut h TaigaConnection) project_exists(name string) bool {
	h.project_get_by_name(name) or {
		if '$err'.contains('cannot find') {
			return false
		}
		panic('cannot check project exists, bug, $err')
	}
	return true
}

// create project if it doesnt exist
pub fn (mut h TaigaConnection) project_create_if_not_exist(name string, description string, projtype Projectype) ?Project {
	if h.project_exists(name) {
		mut project := h.project_get_by_name(name) ?
		project.projtype = projtype
		return project
	}
	return h.project_create(name, description, projtype)
}

// create project based on predefined standards
// return Project obj
pub fn (mut h TaigaConnection) project_create(name string, description string, projtype Projectype) ?Project {
	if h.project_exists(name) {
		return error("Cannot create project with name: '$name' because already exists.")
	}
	mut proj := NewProject{
		description: description
		is_issues_activated: true
		is_private: false
	}
	mut proj_config := NewProjectConfig{}

	match projtype {
		.funnel {
			proj.name = texttools.name_fix('FUNNEL_' + name)
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
			proj.name = texttools.name_fix('PROJECT_' + name)
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
			proj.name = texttools.name_fix('TEAM_' + name)
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
	response := h.post_json_str('projects', postdata, true, true) ?

	h.cache_drop()? //to make sure all is consistent

	mut result := json.decode(Project, response) ?
	result.projtype = projtype
	return result
}
