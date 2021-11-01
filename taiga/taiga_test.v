import taiga {projects, issues, epics, stories, tasks, load}

fn test_main() {
	mut singleton := taiga.new('https://staging.circles.threefold.me', 'admin', '123123', 10000)
	// t.cache_drop() or {panic("Can't drop cache")}
	// println('Taiga Client: $t')
	load() or {panic(err)}
	mut user := singleton.users[13]
	user.projects_per_user_md()
	// mut projects := projects() or { panic('cannot fetch projects. $err') }
	// // println('Found $projects.len projects\nTaiga projects: $projects\n\n')
	// println("-----------------------------------------------------------")
	// println(t.projects)
	// mut project := taiga.project_get(24)  or { panic('cannot fetch project. $err') }
	// all_issues := issues() or { panic(('cannot fetch issues. $err')) }
	// println('Found $t.issues.len issues\nTaiga issues: $t.issues\n\n')
	// users := t.users() or { panic(('cannot fetch users. $err')) }
	// println('Found $users.len users\nTaiga users: $users\n\n')
	// all_stories := stories() or { panic(('cannot fetch stories. $err')) }
	// println('Found $t.stories.len stories\nTaiga stories: $t.stories\n\n')
	// tasks := tasks() or { panic(('cannot fetch tasks. $err')) }
	// println('Found $singleton.tasks.len tasks\nTaiga tasks: $singleton.tasks\n\n')
	// epics := t.epics() or { panic(('cannot fetch epics. $err')) }
	// println('Found $epics.len epics\nTaiga epics: $epics\n\n')

	// mut project_12 := t.project_get_by_name("team_team_test_new_updates") or {panic("Can't get project $err")}
	// println(project_12)

	// mut new_project := t.project_create("add_copy", "This is a project to add copy issues, tasks, epics and stories", taiga.Projectype.funnel) or {panic("Can't create project $err")}
	// println("New Project: $new_project")
	// new_issue := t.issue_create("This is a new issue in project $new_project.id", new_project.id) or {panic("Can't create issue $err")}
	// new_epic := t.epic_create("This is a new epic in project $new_project.id", new_project.id) or {panic("Can't create epic $err")}
	// new_task := t.task_create("This is a new task in project $new_project.id", new_project.id) or {panic("Can't create task $err")}
	// new_us := t.story_create("This is a new story in project $new_project.id", new_project.id) or {panic("Can't create story $err")}
	// copied_issue := project_12.copy(taiga.TaigaElementTypes.issue, 8, new_project.id) or {panic("Can't copy with error: $err")}
	// println(copied_issue)
	// // new_project.delete() or {panic("Can't delete $err")}
	// panic('s')
}
