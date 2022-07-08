module taiga

import freeflowuniverse.crystallib.taigaexports { ProjectExport }

pub fn load_data() ? {
	projects()?
	stories()?
	tasks()?
	issues()?
	epics()?
	users()?
}

// Get elements from singleton obj if found
fn (mut conn TaigaConnection) user_get(id int) &User {
	if id in conn.users.keys() {
		return conn.users[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get user with id: $id from local memory") // print error
	return &User{}
}

fn (mut conn TaigaConnection) story_get(id int) &Story {
	if id in conn.stories.keys() {
		return conn.stories[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get story with id: $id from local memory") // print error
	return &Story{}
}

fn (mut conn TaigaConnection) epic_get(id int) &Epic {
	if id in conn.epics.keys() {
		return conn.epics[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get epic with id: $id from local memory") // print error
	return &Epic{}
}

fn (mut conn TaigaConnection) task_get(id int) &Task {
	if id in conn.tasks.keys() {
		return conn.tasks[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get task with id: $id from local memory") // print error
	return &Task{}
}

fn (mut conn TaigaConnection) issue_get(id int) &Issue {
	if id in conn.issues.keys() {
		return conn.issues[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get issue with id: $id from local memory") // print error
	return &Issue{}
}

fn (mut conn TaigaConnection) project_get(id int) &Project {
	if id in conn.projects.keys() {
		return conn.projects[id] // Get data from singleton obj
	}
	eprintln("[-] Can't get project with id: $id from local memory") // print error
	return &Project{}
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

fn (mut conn TaigaConnection) full_project_remember(id int, obj ProjectExport) {
	conn.full_projects[id] = &obj
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
