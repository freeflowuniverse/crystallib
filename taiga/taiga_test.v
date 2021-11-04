import taiga

fn test_main() {
	url := 'https://staging.circles.threefold.me'
	mut singleton := taiga.new(url, 'admin', '123123', 1000)
	create_issue()
	create_story()
	create_task()
	create_epic()

	// Export user projects as md
	mut user := singleton.users[13]
	export_dir_path := "."
	user.projects_per_user_md(export_dir_path, url)
}

fn create_issue(){
	project_id := 25
	subject := "This is a new issue in project $project_id"
	mut conn := taiga.connection_get()
	mut new_issue := taiga.issue_create(subject, project_id) or { panic("Can't create issue $err") }
	println("✔ Successfully Created a new issue with ID:$new_issue.id")
	issue_from_singleton := conn.issue_get(new_issue.id) or {panic("Can't get issue with error: $err")}
	assert issue_from_singleton.subject == new_issue.subject
	
}

fn create_story(){
	project_id := 25
	subject := "This is a new story in project $project_id"
	mut conn := taiga.connection_get()
	mut new_story := taiga.story_create(subject, project_id) or { panic("Can't create story $err") }
	println("✔ Successfully Created a new story with ID:$new_story.id")
	story_from_singleton := conn.story_get(new_story.id) or {panic("Can't get story with error: $err")}
	assert story_from_singleton.subject == new_story.subject
}

fn create_task(){
	project_id := 25
	subject := "This is a new task in project $project_id"
	mut conn := taiga.connection_get()
	mut new_task := taiga.task_create(subject, project_id) or { panic("Can't create task $err") }
	println("✔ Successfully Created a new task with ID:$new_task.id")
	task_from_singleton := conn.task_get(new_task.id) or {panic("Can't get task with error: $err")}
	assert task_from_singleton.subject == new_task.subject
}

fn create_epic(){
	project_id := 25
	subject := "This is a new epic in project $project_id"
	mut conn := taiga.connection_get()
	mut new_epic := taiga.epic_create(subject, project_id) or { panic("Can't create epic $err") }
	println("✔ Successfully Created a new epic with ID:$new_epic.id")
	epic_from_singleton := conn.epic_get(new_epic.id) or {panic("Can't get epic with error: $err")}
	assert epic_from_singleton.subject == new_epic.subject
}