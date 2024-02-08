module docker

import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct CodeGetArgs {
pub mut:
	url string // e.g.  https://github.com/vlang/v
	// other example url := 'https://github.com/threefoldfoundation/www_examplesite/tree/development/manual'
	pull  bool
	reset bool
	name  string
	dest  string // where does the directory need to be checked out to
}

// checkout a code repository on right location
pub fn (mut r DockerBuilderRecipe) add_codeget(args_ CodeGetArgs) ! {
	mut args := args_
	mut gs := gittools.get(coderoot: '${r.path()}/code')!

	locator := gs.locator_new(args.url)!

	mut gr := gs.repo_get(locator: locator, pull: args.pull, reset: args.reset)!

	if args.name == '' {
		args.name = gr.addr.name
	}

	if args.dest == '' {
		args.dest = '/code/${args.name}'
	}

	// gs.repos_print(filter: '')
	// println(gr)
	// this will show the exact path of the manual
	// println(gr.path_content_get())

	// mut gitaddr := gs.addr_get_from_url(url: url)!

	if args.dest.len < 2 {
		return error("dest is to short (min 3): now '${args.dest}'")
	}

	commonpath := gr.path_relative()
	if commonpath.contains('..') {
		panic('bug should not be')
	}

	r.add_copy(source: commonpath, dest: args.dest)!
}
