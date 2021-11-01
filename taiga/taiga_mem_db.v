module taiga

pub fn load() ?{
	projects() ?
	stories() ?
	issues() ?
	epics() ?
	tasks() ?
	users() ?
}

// // //all internal

fn stories_per_project(project_id int) []Story{
	mut conn := connection_get()
	mut project_stories := []Story{}
	for _, story in conn.stories{
		if story.project == project_id{
			project_stories << story
		}
	}
	return project_stories
}

fn issues_per_project(project_id int) []Issue{
	mut conn := connection_get()
	mut project_issues := []Issue{}
	for _, issue in conn.issues{
		if issue.project == project_id{
			project_issues << issue
		}
	}
	return project_issues
}

fn tasks_per_project(project_id int) []Task{
	mut conn := connection_get()
	mut project_tasks := []Task{}
	for _, task in conn.tasks{
		if task.project == project_id{
			project_tasks << task
		}
	}
	return project_tasks
}

fn epics_per_project(project_id int) []Epic{
	mut conn := connection_get()
	mut project_epics := []Epic{}
	for _, epic in conn.epics{
		if epic.project == project_id{
			project_epics << epic
		}
	}
	return project_epics
}

fn projects_per_user(user_id int) []Project{
	mut conn := connection_get()
	mut all_user_projects := []Project{}
	for id in conn.projects.keys(){
		proj := *conn.projects[id]
		if user_id in proj.members{
			all_user_projects << proj
		}
	}
	return all_user_projects
}

// fn (mut h TaigaConnection) user_get(id int)? &User{

// }

// fn (mut h TaigaConnection) project_get(id int)? &Project{

// }

// fn (mut h TaigaConnection) story_get(id int)? &Story{

// }

// fn (mut h TaigaConnection) epic_get(id int)? &Epic{

// }

// fn (mut h TaigaConnection) task_get(id int)? &Task{

// }

// TODO: do same for other objects
fn user_remember(obj User) {
	// check obj exists in connection, if yes, update & return
	// make sure to remeber the reference !!!
	mut conn := connection_get()
	conn.users[obj.id] = &obj
}

fn project_remember(obj Project) {
	mut conn := connection_get()
	conn.projects[obj.id] = &obj
}

fn issue_remember(obj Issue) {
	mut conn := connection_get()
	conn.issues[obj.id] = &obj
}

fn epic_remember(obj Epic) {
	mut conn := connection_get()
	conn.epics[obj.id] = &obj
}

fn task_remember(obj Task) {
	mut conn := connection_get()
	conn.tasks[obj.id] = &obj
}

fn story_remember(obj Story) {
	mut conn := connection_get()
	conn.stories[obj.id] = &obj
}
