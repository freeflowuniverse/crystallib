module taiga

pub fn load_data() ? {
	projects() ?
	stories() ?
	issues() ?
	epics() ?
	tasks() ?
	users() ?
}

// // //all internal

pub fn stories_per_project(project_id int) []Story {
	mut conn := connection_get()
	mut project_stories := []Story{}
	for id in conn.stories.keys() {
		story := *conn.stories[id]
		if story.project == project_id {
			project_stories << story
		}
	}
	return project_stories
}

pub fn issues_per_project(project_id int) []Issue {
	mut conn := connection_get()
	mut project_issues := []Issue{}
	for id in conn.issues.keys() {
		issue := *conn.issues[id]
		if issue.project == project_id {
			project_issues << issue
		}
	}
	return project_issues
}

pub fn tasks_per_project(project_id int) []Task {
	mut conn := connection_get()
	mut project_tasks := []Task{}
	for id in conn.tasks.keys() {
		task := *conn.tasks[id]
		if task.project == project_id {
			project_tasks << task
		}
	}
	return project_tasks
}

pub fn epics_per_project(project_id int) []Epic {
	mut conn := connection_get()
	mut project_epics := []Epic{}
	for id in conn.epics.keys() {
		epic := *conn.epics[id]
		if epic.project == project_id {
			project_epics << epic
		}
	}
	return project_epics
}

fn projects_per_user(user_id int) []Project {
	mut conn := connection_get()
	mut all_user_projects := []Project{}
	for id in conn.projects.keys() {
		proj := *conn.projects[id]
		if user_id in proj.members {
			all_user_projects << proj
		}
	}
	return all_user_projects
}

// Get elements from singleton obj if found, else get it from API
fn (mut conn TaigaConnection) user_get(id int) ?User {
	if id in conn.users.keys() {
		return *conn.users[id] // Get data from singleton obj
	}
	return user_get(id) // Get data from API
}

fn (mut conn TaigaConnection) story_get(id int) ?Story {
	if id in conn.stories.keys() {
		return *conn.stories[id] // Get data from singleton obj
	}
	return story_get(id) // Get data from API
}

fn (mut conn TaigaConnection) epic_get(id int) ?Epic {
	if id in conn.epics.keys() {
		return *conn.epics[id] // Get data from singleton obj
	}
	return epic_get(id) // Get data from API
}

fn (mut conn TaigaConnection) task_get(id int) ?Task {
	if id in conn.tasks.keys() {
		return *conn.tasks[id] // Get data from singleton obj
	}
	return task_get(id) // Get data from API
}

fn (mut conn TaigaConnection) issue_get(id int) ?Issue {
	if id in conn.issues.keys() {
		return *conn.issues[id] // Get data from singleton obj
	}
	return issue_get(id) // Get data from API
}

// Remember and update elements in singleton obj
fn (mut conn TaigaConnection) user_remember(obj User) {
	// check obj exists in connection, if yes, update & return
	// make sure to remeber the reference !!!
	conn.users[obj.id] = &obj
}

fn (mut conn TaigaConnection) project_remember(obj Project) {
	conn.projects[obj.id] = &obj
}

fn (mut conn TaigaConnection) issue_remember(obj Issue) {
	conn.issues[obj.id] = &obj
}

fn (mut conn TaigaConnection) epic_remember(obj Epic) {
	conn.epics[obj.id] = &obj
}

fn (mut conn TaigaConnection) task_remember(obj Task) {
	conn.tasks[obj.id] = &obj
}

fn (mut conn TaigaConnection) story_remember(obj Story) {
	conn.stories[obj.id] = &obj
}

// Forget elements from singleton obj
fn (mut conn TaigaConnection) user_forget(id int) {
	conn.users.delete(id)
}

fn (mut conn TaigaConnection) project_forget(id int) {
	conn.projects.delete(id)
}

fn (mut conn TaigaConnection) issue_forget(id int) {
	conn.issues.delete(id)
}

fn (mut conn TaigaConnection) epic_forget(id int) {
	conn.epics.delete(id)
}

fn (mut conn TaigaConnection) task_forget(id int) {
	conn.tasks.delete(id)
}

fn (mut conn TaigaConnection) story_forget(id int) {
	conn.stories.delete(id)
}
