module taiga
import json
import x.json2

struct DefaultOptions {
	issue_status string
	issue_type string
	priority string
	severity string
	task_status string
	us_status string
}

// As we use name only in each status or type we will use it as common struct
// If this way changed later we have to create a struct for each status or type
struct Status {
	name string
}
struct ProjectTemplate {
	default_options DefaultOptions
	description string
	is_backlog_activated bool
	is_issues_activated bool
	is_kanban_activated bool
	is_wiki_activated bool
	issue_statuses []Status
	issue_types []Status
	name string
	priorities []Status
	severities []Status
	slug string
	task_statuses []Status
	us_statuses []Status
}
pub fn project_templates() ? map[string]int {
	// In this function we will get project templates if we found them --> return them as map[name]ID
	// If no templates --> create 3 templates according to our standards and return them as map[name]ID
	mut conn := connection_get()
	mut result := map[string]int
	mut found_funnel := false
	mut found_project := false
	mut found_team := false

	response := conn.get_json_str("project-templates", '', true) ?
	response_as_arr := (json2.raw_decode(response) or {}).arr()
	println("Decoded as Arr")
	for pt in response_as_arr{
		decoded_pt := (json2.raw_decode(pt.str()) or {}).as_map()
		println(" - Decoded as Map")
		template_name := decoded_pt["name"].str()
		found_funnel = if template_name == Projectype.funnel.str() { true } else { false }
		found_project = if template_name == Projectype.project.str() { true } else { false }
		found_team = if template_name == Projectype.team.str() { true } else { false }
		result[decoded_pt["name"].str()] = decoded_pt["id"].int()
	}
	println(found_funnel)
	println(found_project)
	println(found_team)
	
	create_result := create_project_templates(found_funnel, found_project, found_team) ?
	for k, v in create_result {
		result[k] = v
	}
	return result
}

fn create_project_templates(funnel bool, project bool, team bool) ? map[string]int {
	// FIXME: Create not working due to taiga-back issue --> https://github.com/kaleidos-ventures/taiga-back/issues/60
	// This function expected to be called one time with first time client started if project templates not created
	mut conn := connection_get()
	mut result := map[string]int
	mut templates := []ProjectTemplate
	if !funnel{
		templates << ProjectTemplate{
			name: "funnel"
			description: "Funnel predefined type for a new circle"
			is_backlog_activated: false
			is_issues_activated: true
			is_kanban_activated: true
			is_wiki_activated: true
			issue_statuses: [Status{name:'New'}, Status{name:'Interested'}, Status{name:'Deal'}, Status{name:'Blocked'}, Status{name:'NeedInfo'}, Status{name:'Lost'}, Status{name:'Postponed'}, Status{name:'Won'}]
			issue_types: [Status{name: "opportunity"}]
			priorities: [Status{name:'Low'}, Status{name:'Normal'}, Status{name:'High'}]
			severities: [Status{name:'unknown'}, Status{name:'low'}, Status{name:'25%'}, Status{name:'50%'}, Status{name:'75%'}, Status{name:'90%'}]
			task_statuses: [Status{name:'New'}, Status{name:'In progress'}, Status{name:'Verification'}, Status{name:'Needs info'}, Status{name:'Closed'}]
			us_statuses: [Status{name:'New'}, Status{name:'Proposal'}, Status{name:'Contract'}, Status{name:'Blocked'}, Status{name:'NeedInfo'}, Status{name:'Closed'}]
			default_options: DefaultOptions{
				issue_status: 'New'
				issue_type: 'opportunity'
				priority:  'Low'
				severity: 'unknown'
				task_status: 'New'
				us_status: 'New'
			}
		}
	}
	if !project{
		templates << ProjectTemplate{
			name: "project"
			description: "Project predefined type for a new circle"
			is_backlog_activated: false
			is_issues_activated: true
			is_kanban_activated: true
			is_wiki_activated: false
			issue_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Implemented'}, Status{name:'Closed'}, Status{name:'Postponed'}, Status{name:'Rejected'}, Status{name:'Archived'}]
			issue_types: [Status{name: "Bug"}, Status{name: "Question"}, Status{name: "Enhancement"}]
			priorities: [Status{name:'Low'}, Status{name:'Normal'}, Status{name:'High'}]
			severities: [Status{name:'Wishlist'}, Status{name:'Minor'}, Status{name:'Normal'}, Status{name:'Important'}, Status{name:'Critical'}]
			task_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Done'}]
			us_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Implemented'}, Status{name:'Verified'}, Status{name:'Archived'}]
			default_options: DefaultOptions{
				issue_status: 'New'
				issue_type: 'Bug'
				priority:  'Low'
				severity: 'Wishlist'
				task_status: 'New'
				us_status: 'New'
			}
		}

	}

	if !team{
		templates << ProjectTemplate{
			name: "team"
			description: "Team predefined type for a new circle"
			is_backlog_activated: true
			is_issues_activated: true
			is_kanban_activated: false
			is_wiki_activated: true
			issue_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Implemented'}, Status{name:'Closed'}, Status{name:'Postponed'}, Status{name:'Rejected'}, Status{name:'Archived'}]
			issue_types: [Status{name: "Bug"}, Status{name: "Question"}, Status{name: "Enhancement"}]
			priorities: [Status{name:'Low'}, Status{name:'Normal'}, Status{name:'High'}]
			severities: [Status{name:'Wishlist'}, Status{name:'Minor'}, Status{name:'Normal'}, Status{name:'Important'}, Status{name:'Critical'}]
			task_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Done'}]
			us_statuses: [Status{name:'New'}, Status{name:'to-start'}, Status{name:'in-progress'}, Status{name:'Blocked'}, Status{name:'Implemented'}, Status{name:'Verified'}, Status{name:'Archived'}]
			default_options: DefaultOptions{
				issue_status: 'New'
				issue_type: 'Bug'
				priority:  'Low'
				severity: 'Wishlist'
				task_status: 'New'
				us_status: 'New'
			}
		}
	}

	for template in templates {
		println(template)
		encoded_data := json.encode_pretty(template)
		println(encoded_data)
		response := conn.post_json("project_templates", encoded_data, false, true) ?
		println(response)
		result[response["name"].str()] = response["id"].int()
	}
	return result
}