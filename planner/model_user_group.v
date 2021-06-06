module planner

pub struct User {
pub mut:
	id          int
	name        string
	email       string
	github_name string
}

pub struct Group {
pub mut:
	id      int
	name    string
	members []string
}
