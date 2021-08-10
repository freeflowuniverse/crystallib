module builder

struct GitRepoState {
}

struct GitRepo {
	name           string
	url            string
	commit_message string
	actions        []GitAction
pub mut:
	state GitRepoState
}

// reset means we lose the changes
enum GitAction {
	commit
	pull
	push
	reset
}

// life cycle management of a git repo
// make sure the git repo is there
pub fn (mut repo GitRepo) prepare(wish Wish) ? {
}

// nothing to do
pub fn (mut repo GitRepo) start(wish Wish) ? {
}

// check if repo is there and all ok
pub fn (mut repo GitRepo) check(wish Wish) ? {
}

// check if we are in right state if not lets try to recover
pub fn (mut repo GitRepo) recover(wish Wish) ? {
}

// return relevant info of the package
pub fn (mut repo GitRepo) info(wish Wish) ? {
}

// not relevant for packages
pub fn (mut repo GitRepo) halt(wish Wish) ? {
}

// remove from the system
pub fn (mut repo GitRepo) delete(wish Wish) ? {
}
