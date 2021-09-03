module gittools

pub enum GitStructureStatus {
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
struct GitStructure {
pub mut:
	multibranch bool
	root  string	
	repos []GitRepo
	status GitStructureStatus
}

struct GitRepo {
	id int [skip]
	//only use when custom path
	path path.Path
mut:
	gitstructure &GitStructure
pub mut:
	addr  GitAddr
	state GitStatus
}

struct GitAddr {
	// root string
pub mut:
	provider string
	account  string
	name     string // is the name of the repository
	path     string // path in the repo (not on filesystem)
	branch   string
	anker    string // position in the file
	depth    int    // 0 means we have all depth
}
