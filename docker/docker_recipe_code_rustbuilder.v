module docker

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib


[params]
pub struct RustBuildArgs {
pub mut:
	url string // e.g.  https://github.com/valeriansaliou/sonic
	pull  bool
	reset bool
	buildcmd string = 'cargo build --release'
	copycmd string = ''
	debug bool //to be able to easily debug the intermediate step
	name  string
}

// do a build of a rust package .
// will get the code, pull and/or reset .
// will the pull all dependencies .
// will do the build
// DEBUG TRICK: put debug flag on, which will not execute the build cmd .
//    you can go to /tmp/build/buildname and do shell.sh to debug
pub fn (mut r DockerBuilderRecipe) add_rustbuild_from_code(args RustBuildArgs) ! {

	r.add_codeget(url:args.url,name:args.name,reset:args.reset,pull:args.pull)!

	r.add_run(cmd: '
		source ~/.cargo/env
		cd /code/${args.name}		
		cargo update --dry-run
		')!

	if !args.debug{
		r.add_run(
			cmd: '
			source ~/.cargo/env
			cd /code/${args.name}	
			${args.buildcmd}
			${args.copycmd}
			'
		)!
	}

}

[params]
pub struct RustPackageArgs {
pub mut:
	name string // can be comma separated
	copycmd string = '' //normally empty
}

//use cargo install to install rust components
pub fn (mut r DockerBuilderRecipe) add_rust_package(args RustPackageArgs) ! {

	if args.name == ''  {
		return error('name cannot be empty, name can be comma separated')
	}
	mut names:=[]string
	if args.name.contains(',') {
		for item2 in args.name.split(',') {
			names << item2.trim_space()
		}
	} else {
		if args.name != '' {
			names << args.name.trim_space()
		}
	}

	for name in names{
		r.add_run(cmd: '
			source ~/.cargo/env
			cargo install ${name}
			${args.copycmd}
			')!
	}

}