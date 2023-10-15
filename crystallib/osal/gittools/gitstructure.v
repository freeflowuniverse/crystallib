module gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
[heap]
pub struct GitStructure {
	config   GitStructureConfig // configuration settings
	rootpath pathlib.Path = pathlib.get('~/code') // path to root code directory
pub mut:
	name   string = 'default' // key indexing global gitstructure
	repos  []&GitRepo // repositories in gitstructure
}

//remove cache
fn (gs GitStructure) cachereset() ! {
	mut redis := redisclient.core_get()!
	key_check := 'git:cache:*'
	keys := redis.keys(key_check)!
	for key in keys {
		// println(key)
		redis.del(key)!
	}
}

//internal function to be executed in thread
fn repo_thread_refresh(r GitRepo)  {
	r.load() or {panic(err)}
}

pub fn (gs GitStructure) reload() ! {
	gs.cachereset()!
	mut threads := []thread{}
	for r in instances[gs.name].repos {
		threads<<spawn repo_thread_refresh(r ) 
	}
	threads.wait()
	println(' - all repo refresh jobs finished.')
}



pub fn (mut gitstructure GitStructure) list(args ReposGetArgs)! {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)!
	println('')
}


pub fn (mut gitstructure GitStructure) repo_from_path(path string)!GitRepo {
	mut r:=GitRepo {
		gs:&gitstructure
		addr:GitAddr{gs:&gitstructure}
		path:pathlib.get_dir(path,false)!
	}
	r.load_from_path()!
	return r
}

