module taiga

import despiegk.crystallib.crystaljson
import json

fn project_decode(data string) ?Project {
	data_as_map := crystaljson.json_dict_any(data, false, [], []) ?
	mut project := json.decode(Project, data) ?

	project.created_date = parse_time(data_as_map['created_date'].str())
	project.modified_date = parse_time(data_as_map['modified_date'].str())
	project.file_name = generate_file_name(project.name + '.md')
	return project
}

pub fn (project Project) delete() ?bool {
	mut conn := connection_get()
	return conn.delete('projects', project.id)
}

pub fn (project Project) stories() []Story {
	mut conn := connection_get()
	mut project_stories := []Story{}
	for id in conn.stories.keys() {
		story := *conn.stories[id]
		if story.project == project.id {
			project_stories << story
		}
	}
	return project_stories
}

pub fn (project Project) issues() []Issue {
	mut conn := connection_get()
	mut project_issues := []Issue{}
	for id in conn.issues.keys() {
		issue := *conn.issues[id]
		if issue.project == project.id {
			project_issues << issue
		}
	}
	return project_issues
}

pub fn (project Project) tasks() []Task {
	mut conn := connection_get()
	mut project_tasks := []Task{}
	for id in conn.tasks.keys() {
		task := *conn.tasks[id]
		if task.project == project.id {
			project_tasks << task
		}
	}
	return project_tasks
}

pub fn (project Project) epics() []Epic {
	mut conn := connection_get()
	mut project_epics := []Epic{}
	for id in conn.epics.keys() {
		epic := *conn.epics[id]
		if epic.project == project.id {
			project_epics << epic
		}
	}
	return project_epics
}

pub fn (project Project) owner() User {
	mut conn := connection_get()
	user := conn.users[project.owner]
	return *user
}

pub fn (project Project) as_md(url string) string {
	mut proj_md := $tmpl('./templates/project.md')
	proj_md = fix_empty_lines(proj_md)
	return proj_md
}
