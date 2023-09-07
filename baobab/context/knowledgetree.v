module context

import freeflowuniverse.crystallib.knowledgetree

pub fn (mut c Context) knowledgetree() !knowledgetree.Tree {
	if c.knowledgetree == none {
		c.knowledgetree = knowledgetree.new()!
	}
	return c.knowledgetree or { panic(err) }
}

fn (mut c Context) knowledgetree_init(mut actions Actions, action Action) ! {
}
