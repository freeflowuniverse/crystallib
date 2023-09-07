module context

import freeflowuniverse.crystallib.gittools

pub fn (mut c Context) gitstructure(name_ string) !gittools.GitStructure {
	name := texttools.name_fix(name_)
	if name !in c.gitstructure {
		return error('Could not find gitstructure with name ${name}, use !!git.init ')
	}
	return c.gitstructure[name] or { panic(err) }
}

// init new gitstructure
//```
//  gitname 	    string
// 	filter      string
// 	multibranch bool
// 	root        string // where will the code be checked out
// 	pull        bool   // means we will pull even if the directory exists
// 	reset       bool   // be careful, this means we will reset when pulling
// 	light       bool   // if set then will clone only last history for all branches		
// 	log         bool   // means we log the git statements
//```
pub fn (mut c Context) gitstructure_new(args_ gittools.GSConfig) ! {
	c.gitstructure[name] = gittools.new(args_)!
}

// params for the action
//```
//  gitname 	    string
// 	filter      string
// 	multibranch bool
// 	root        string // where will the code be checked out
// 	pull        bool   // means we will pull even if the directory exists
// 	reset       bool   // be careful, this means we will reset when pulling
// 	light       bool   // if set then will clone only last history for all branches		
// 	log         bool   // means we log the git statements
//```
fn git_init(mut c Context, mut actions Actions, action Action) ! {
	if action.name == 'init' {
		gitname := action.params.get_string_default('gitname', 'default')!
		filter := action.params.get_string_default('filter', '')!
		root := action.params.get_string_default('root', '')!
		pull := action.params.get_default_false('pull')!
		reset := action.params.get_default_false('reset')!
		light := action.params.get_default_true('light')!
		log := action.params.get_default_false('log')!

		c.gitstructure[name] = gittools.new(
			gitname: gitname
			filter: filter
			root: root
			pull: pull
			reset: reset
			light: light
			log: log
		)!
	}
}
