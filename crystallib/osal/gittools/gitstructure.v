module gittools

[heap]
pub struct GitStructure {
	config   GitStructureConfig // configuration settings
	rootpath pathlib.Path = pathlib.get('~/code') // path to root code directory
pub mut:
	name   string = 'default' // key indexing global gitstructure
	repos  []&GitRepo // repositories in gitstructure
	status GitStructureStatus
}

pub enum GitStructureStatus {
	new
	init
	loaded
	error
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

//internal function to be executed in thread
fn repo_thread_refresh(r GitRepo)  {
	r.refresh(reload:true) or {panic(err)}
}

pub fn (gs GitStructure) reload() ! {
	gs.cachereset()!
		mut threads := []thread{}
		for r in instances[args.name].repos {
			threads<<spawn repo_thread_refresh(r ) 
		}
		threads.wait()
		println(' - all repo refresh jobs finished.')
	}

	return error('Canot find gitstructure with name ${args.name} to reload.')
}
