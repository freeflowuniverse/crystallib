module context

import freeflowuniverse.crystallib.gittools


pub fn (mut c Context) gitstructure() !gittools.GitStructure {
	if c.gitstructure == none{
		c.gitstructure = gittools.get()!
	}
	return c.gitstructure or {panic(err)}
}


// params for the action
//```
// 	filter      string
// 	multibranch bool
// 	root        string // where will the code be checked out
// 	pull        bool   // means we will pull even if the directory exists
// 	reset       bool   // be careful, this means we will reset when pulling
// 	light       bool   // if set then will clone only last history for all branches		
// 	log         bool   // means we log the git statements
//```
fn (mut c Context) git_init(mut actions Actions, action Action) ! {

	if action.name == "init"{

		filter:=action.params.get_string_default(filter,"")!
		root:=action.params.get_string_default(root,"")!
		pull:=action.params.get_default_false(pull)!
		reset:=action.params.get_default_false(reset)!
		light:=action.params.get_default_true(light)!
		log:=action.params.get_default_false(log)!

		c.gitstructure:=gittools.new(filter:filter,root:root,pull:pull,reset:reset,light:light,log:log)!

	}


}

