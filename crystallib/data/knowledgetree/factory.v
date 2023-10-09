module knowledgetree

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.baobab.context
import log

__global (
	knowledgetrees shared map[string]Tree
)

[params]
pub struct ArgsNew {
pub mut:
	name string = 'default'
}

// get a new tree initialized
// will create a new tree instance, be careful
pub fn new(args_ ArgsNew) ! {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	level := match osal.env_get_default('KNOWLEDGETREE_LOG_LEVEL', 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	lock knowledgetrees {
		mut t := Tree{
			name: args.name
			logger: &log.Log{
				level: level
			}
		}
		t.init()! // initialize mdbooks embed logic
		knowledgetrees[args.name] = t
	}
}

pub struct MacroProcessorArgs {
mut:
	processor IMacroProcessor
	name      string
}

pub fn macroprocessor_add(args_ MacroProcessorArgs) ! {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	lock knowledgetrees {
		mut tree := knowledgetrees[args.name] or { return error('cannot find tree: ${args.name}') }
		tree.macroprocessor_add(args_.processor)!
		knowledgetrees[args.name] = tree
	}
}

[params]
pub struct ArgsGet {
pub mut:
	treename string = 'default'
	name     string
}

pub fn collection_get(args_ ArgsGet) !Collection {
	mut args := args_
	args.treename = texttools.name_fix(args.treename)
	rlock knowledgetrees {
		mut tree := knowledgetrees[args.treename] or {
			return error('cannot find tree: ${args.treename}')
		}
		return tree.collection_get(args.name)!
	}
	panic('should not get here')
}

// pub fn mdbook_generate( treename string, collectionname string) !Collection {
// 	treename2:=texttools.name_fix(treename)
// 	rlock knowledgetrees{
// 		mut tree:=knowledgetrees[treename2] or { return error("cannot find tree: $treename2") }
// 		return tree.collection_get(collectionname)!
// 	}
// 	panic("should not get here")

// }