module context

__global (
	context = Context{}
)

fn init() {
	context.init()
}


import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.bizmodel
import freeflowuniverse.crystallib.knowledgetree

// this is nr of factory classes we might need depending the context
pub struct Context {
mut:
	gitstructure  ?gittools.GitStructure
	spawner       ?spawner.Spawner
	knowledgetree map[string]knowledgetree.Tree
	bizmodels     map[string]bizmodel.BizModel
	init_3scripts []string // remeber list of init 3scripts, so we can re-execute in thread
}

// pub fn new() Context {
// 	return Context{}
// }

pub fn (mut c Context) str() string {
	mut out := '## Context\n\n'

	if c.gitstructure != none {
		out += '- gitstructure: ${c.gitstructure().root}\n'
	}
	if c.gitstructure != none {
		out += '- knowledgetree:\n'
		for key, tree in c.knowledgetree {
			out += '    - ${key}\n'
		}
	}
	if c.bizmodels.len > 0 {
		out += '- bizmodels:\n'
		for key, bm in c.bizmodels {
			out += '    - ${key}\n'
		}
	}

	return out
}

// initialize the context using 3script
pub fn (mut c Context) init(script3 string) ! {
	mut actions := actions.new(text: script3)!
	for prio in 0 .. 11 {
		for action in actions.actions {
			if action.prio == prio {
				match action.actor.to_lower() {
					'git' {
						git_init(mut c, mut actions, action)!
					}
					'knowledgetree' {
						knowledgetree_init(mut c, mut actions, action)!
					}
					'bizmodel' {
						bizmodel_init(mut c, mut actions, action)!
					}
				}
			}
		}
	}
}
