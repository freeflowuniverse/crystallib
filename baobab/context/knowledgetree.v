module context

import freeflowuniverse.crystallib.knowledgetree



pub fn (mut c Context) knowledgetree() !knowledgetree.Tree {
	if c.knowledgetree == none{
		c.knowledgetree = knowledgetree.new(mut c)!	
	}
	return c.knowledgetree or {panic(err)}
}



fn (mut c Context) knowledgetree_init(mut actions Actions, action Action) ! {


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

