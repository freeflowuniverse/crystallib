module gittools

// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base

@[heap]
pub struct GitStructure {
pub mut:
	key string //unique key for the git structure is hash of the path or default which is $home/code
	config   GitStructureConfig // configuration settings
	coderoot pathlib.Path
	repos    map[string]&GitRepo // repositories in gitstructure
	loaded   bool
}




// will get repo starting from url, if the repo does not exist, only then will pull .
// if pull is set on true, will then pull as well .
// url examples: .
// ```
// https://github.com/threefoldtech/tfgrid-sdk-ts
// https://github.com/threefoldtech/tfgrid-sdk-ts.git
// git@github.com:threefoldtech/tfgrid-sdk-ts.git
//
// # to specify a branch and a folder in the branch
// https://github.com/threefoldtech/tfgrid-sdk-ts/tree/development/docs
//
// args:
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
// will return the path of the location 
pub fn (mut gs GitStructure) code_get(args_ GSCodeGetFromUrlArgs) !string {

	mut r:=gs.repo_get(args_)!

	return r.addr.locator.path_on_fs()!

}

pub fn (mut gitstructure GitStructure) check() ! {
	mut done := []string{}
	for r in gitstructure.keys() {
		if r in done {
			return error('found double repo with key:${r}')
		}
		done << r
	}
}

fn (mut gs GitStructure) keys() []string {
	mut repokeys := gs.repos.map(it.addr.key())
	return repokeys
}

fn (mut gs GitStructure) repo_set_(repo &GitRepo) ! {

	//todo
	if true{panic("implement")}

	// if repo.key() in gs.keys() {
	// 	return
	// }
	// gs.repos << repo
}




pub fn (mut gitstructure GitStructure) list(args ReposGetArgs) ! {
	// texttools.print_clear()
	console.print_debug(' #### overview of repositories:')
	console.print_debug('')
	gitstructure.repos_print(args)!
	console.print_debug('')
}


pub fn (mut gitstructure GitStructure) cachereset() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	keys := redis.keys("git:cache:${gitstructure.key}:**")!
	for key in keys {
		redis.del(key)!
	}
}

