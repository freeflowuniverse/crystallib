module gittools

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools

[heap]
pub struct GitStructure {
	config   GitStructureConfig // configuration settings
	rootpath pathlib.Path = pathlib.get('~/code') // path to root code directory
pub mut:
	repos []&GitRepo // repositories in gitstructure
}

fn (gs GitStructure) cache_key() string {
	return gitstructure_cache_key(gs.name())
}

fn (gs GitStructure) name() string {
	return gs.config.name
}

// remove cache
fn (gs GitStructure) cache_reset() ! {
	mut redis := redisclient.core_get()!
	key_check := gs.cache_key()
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

pub fn (mut gitstructure GitStructure) list(args ReposGetArgs) ! {
	// texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)!
	println('')
}


pub fn (mut gitstructure GitStructure) repo_from_path(path string) !GitRepo {
	mut r := GitRepo{
		gs: &gitstructure
		addr: GitAddr{
			gsconfig: gitstructure.config
		}
		path: pathlib.get_dir(path: path)!
	}
	// r.load_from_path()!
	return r
}
