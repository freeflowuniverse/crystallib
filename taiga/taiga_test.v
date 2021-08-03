module taiga

fn test_main() {
	mut t := new("circles.threefold.me","despiegk","kds007kds",10)
	projects := t.projects() or {panic("cannot fetch projects. $err")}
	println(projects)
	panic("s")
}
