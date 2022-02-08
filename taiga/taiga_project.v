module taiga

import despiegk.crystallib.crystaljson

fn project_decode(data string) ?Project {
	data_as_map := crystaljson.json_dict_filter_any(data, false, [], []) ?
	mut project := Project{
		name: data_as_map['name'].str()
		description: data_as_map['description'].str()
		id: data_as_map['id'].int()
		is_private: data_as_map['is_private'].bool()
		slug: data_as_map['slug'].str()
		owner: data_as_map['owner'].as_map()['id'].int()
	}
	for tag in data_as_map['tags'].arr() {
		project.tags << tag.str()
	}
	for member in data_as_map['members'].arr() {
		if member.int() != 0 {
			project.members << member.int()
		}
	}
	project.created_date = parse_time(data_as_map['created_date'].str())
	project.modified_date = parse_time(data_as_map['modified_date'].str())
	project.file_name = generate_file_name(project.name + '.md')
	return project
}

pub fn (project Project) delete() ?bool {
	mut conn := connection_get()
	return conn.delete('projects', project.id)
}

pub fn (project Project) stories() []&Story {
	mut conn := connection_get()
	mut project_stories := []&Story{}
	for id, _ in conn.stories {
		story := conn.story_get(id)
		if story.project == project.id {
			project_stories << story
		}
	}
	return project_stories
}

pub fn (project Project) issues() []&Issue {
	mut conn := connection_get()
	mut project_issues := []&Issue{}
	for id, _ in conn.issues {
		issue := conn.issue_get(id)
		if issue.project == project.id {
			project_issues << issue
		}
	}
	return project_issues
}

pub fn (project Project) tasks() []&Task {
	mut conn := connection_get()
	mut project_tasks := []&Task{}
	for id, _ in conn.tasks {
		task := conn.task_get(id)
		if task.project == project.id {
			project_tasks << task
		}
	}
	return project_tasks
}

pub fn (project Project) epics() []&Epic {
	mut conn := connection_get()
	mut project_epics := []&Epic{}
	for id, _ in conn.epics {
		epic := conn.epic_get(id)
		if epic.project == project.id {
			project_epics << epic
		}
	}
	return project_epics
}

pub fn (project Project) owner() &User {
	mut conn := connection_get()
	return conn.user_get(project.owner)
}

pub fn (project Project) as_md(url string) string {
	stories := project.stories()
	issues := project.issues()
	tasks := project.tasks()
	owner := project.owner()
	// epics := project.epics() //TODO: Later
	mut proj_md := $tmpl('./templates/project.md')
	proj_md = fix_empty_lines(proj_md)
	return proj_md
}
