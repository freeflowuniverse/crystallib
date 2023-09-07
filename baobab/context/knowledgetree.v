module context

import freeflowuniverse.crystallib.knowledgetree
import freeflowuniverse.crystallib.texttools

pub fn (mut c Context) knowledgetree(name_ string) !knowledgetree.Tree {
	name := texttools.name_fix(name_)
	if name !in c.knowledgetree {
		c.knowledgetree[name] = knowledgetree.new(mut c, name)!
	}
	return c.knowledgetree[name] or { panic(err) }
}

pub fn knowledgetree_init(mut c Context, mut actions Actions, action Action) ! {
	if action.name == 'init' {
		mut name := action.params.get_string('name')!
		name = texttools.name_fix(name)

		c.knowledgetree(name)!
	}
}
