import  despiegk.crystallib.taiga

fn test_main() {
	mut t := taiga.new("https://staging.circles.threefold.me","admin","123123",10)
	println("Taiga Client: $t")
	mut projects := t.projects() or {panic("cannot fetch projects. $err")}
	println("Found $projects.len projects\nTaiga projects: $projects\n\n")
	issues := t.issues() or {panic(("cannot fetch issues. $err"))}
	println("Found $issues.len issues\nTaiga issues: $issues\n\n")
	users := t.users() or {panic(("cannot fetch users. $err"))}
	println("Found $users.len users\nTaiga users: $users\n\n")
	userstories := t.userstories() or {panic(("cannot fetch userstories. $err"))}
	println("Found $userstories.len userstories\nTaiga userstories: $userstories\n\n")
	tasks := t.tasks() or {panic(("cannot fetch tasks. $err"))}
	println("Found $tasks.len tasks\nTaiga tasks: $tasks\n\n")
	epics := t.epics() or {panic(("cannot fetch epics. $err"))}
	println("Found $epics.len epics\nTaiga epics: $epics\n\n")

	mut new_project := t.project_create_if_not_exist("team_test_new_updates", "This is a team test project", taiga.Projectype.team) or {panic("Can't create project $err")}
	println("New Project: $new_project")
	t.issue_create("This is a new issue in project $new_project.id", new_project.id) or {panic("Can't create issue $err")}
	// new_epic := t.epic_create("This is a new epic in project $new_project", new_project.id) or {panic("Can't create epic $err")}
	// new_task := t.task_create("This is a new task in project $new_project", new_project.id) or {panic("Can't create task $err")}
	// new_us := t.userstory_create("This is a new userstory in project $new_project", new_project.id) or {panic("Can't create userstory $err")}
	// new_project.delete() or {panic("Can't delete $err")}
	panic("s")
}
