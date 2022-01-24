module taiga

import despiegk.crystallib.texttools
import json
// import x.json2 { raw_decode }
import despiegk.crystallib.crystaljson

pub fn projects() ?[]Project {
	// List all Projects
	mut conn := connection_get()
	blocks := conn.get_json_list('projects', '', true) ?
	println('[+] Loading $blocks.len projects ...')
	mut projects := []Project{}
	for proj in blocks {
		project := project_decode(proj) or {
			eprintln(err)
			Project{}
		}
		if project != Project{} {
			if !project.name.to_lower().contains('archive') {
				projects << project
				conn.project_remember(project)
			}
		}
	}
	return projects
}

// get the project
pub fn (mut h TaigaConnection) project_get_by_name(name string) ?Project {
	// Get project by name
	// because we cache we can walk over it
	mut conn := connection_get()
	name2 := texttools.name_clean(name)
	mut all_projects := projects() ?
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
pub fn (mut h TaigaConnection) project_create_if_not_exist(name string, description string, projtype ProjectType) ?Project {
	if h.project_exists(name) {
		mut project := h.project_get_by_name(name) ?
		project.projtype = projtype
		return project
	}
	return project_create(name, description, projtype)
}

// create project based on predefined standards
// return Project obj
pub fn project_create(name string, description string, projtype ProjectType) ?Project {
	mut conn := connection_get()
	if conn.project_exists(name) {
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
			proj.name = texttools.name_clean('FUNNEL_' + name)
			proj.is_backlog_activated = false
			proj.is_kanban_activated = true
			proj.is_wiki_activated = true

			proj_config.severities << ['unknown', 'low', '25%', '50%', '75%', '90%']
			proj_config.priorities << ['Low', 'Normal', 'High']
			proj_config.issues_types << 'opportunity'
			proj_config.issues_statuses << ['New', 'Interested', 'Deal', 'Blocked', 'NeedInfo',
				'Lost', 'Postponed', 'Won']
			proj_config.story_statuses << ['New', 'Proposal', 'Contract', 'Blocked', 'NeedInfo',
				'Closed']
			proj_config.task_statuses << ['New', 'In progress', 'Verification', 'Needs info',
				'Closed']
			proj_config.custom_fields << ['bookings', 'commission']
		}
		.project {
			proj.name = texttools.name_clean('PROJECT_' + name)
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
			proj.name = texttools.name_clean('TEAM_' + name)
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
		else {}
	}
	postdata := json.encode_pretty(proj)
	response := conn.post_json_str('projects', postdata, true) ?

	mut result := project_decode(response) ?
	result.projtype = projtype
	conn.project_remember(result)
	return result
}
