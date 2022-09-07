module gittools

pub enum GitStructureStatus {
	new
	init
	loaded
	error
}

pub enum GitStatus {
	unknown
	changes
	ok
	error
}

[heap]
pub struct GitStructure {
pub mut:
	config GSConfig
	repos  []GitRepo
	status GitStructureStatus
}

[heap]
pub struct GitRepo {
	id int [skip]
pub:
	// only use when custom path
	path string
	name string
pub mut:
	gs    &GitStructure [str: skip]
	addr  GitAddr
	state GitStatus
}

pub struct GitAddr {
pub mut:
	// root string
	provider string
	account  string
	name     string // is the name of the repository
	path     string // path in the repo (not on filesystem)
	branch   string
	anker    string // position in the file
	depth    int    // 0 means we have all depth
}
