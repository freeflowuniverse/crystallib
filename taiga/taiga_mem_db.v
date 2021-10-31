module taiga

// // //all internal

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
