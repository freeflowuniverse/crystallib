module gittools

pub enum GitStatus {
	unknown
	changes
	ok
	error
}

struct GitStructure {
pub mut:
	root  string
	repos []GitRepo
}

struct GitRepo {
	id int [skip]
pub:
	path string // path on filesystem
	depth    int    // 0 means we have all depth
pub mut:
	addr  GitAddr
	state GitStatus
}

