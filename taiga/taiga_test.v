import  despiegk.crystallib.taiga

fn test_main() {
	mut t := taiga.new("circles.threefold.me","despiegk","kds007kds",10)
	projects := t.projects() or {panic("cannot fetch projects. $err")}
	issues := t.issues() or {panic(("cannot fetch issues. $err"))}
	users := t.users() or {panic(("cannot fetch users. $err"))}
	userstories := t.userstories() or {panic(("cannot fetch userstories. $err"))}
	tasks := t.tasks() or {panic(("cannot fetch tasks. $err"))}
	epics := t.epics() or {panic(("cannot fetch epics. $err"))}
	println("Found $projects.len projects\nTaiga projects: $projects\n\n")
	println("Found $issues.len issues\nTaiga issues: $issues\n\n")
	println("Found $users.len users\nTaiga users: $users\n\n")
	println("Found $userstories.len userstories\nTaiga userstories: $userstories\n\n")
	println("Found $tasks.len tasks\nTaiga tasks: $tasks\n\n")
	println("Found $epics.len epics\nTaiga epics: $epics\n\n")
}
