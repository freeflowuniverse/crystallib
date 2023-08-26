module docker

pub fn (mut r DockerBuilderRecipe) add_gobuilder() ! {
	r.add_package(name: 'musl-dev,gcc, g++, go, make')!
	r.add_env('GOPATH', '/app')!
	r.add_workdir(workdir: '/app')!
}


[params]
pub struct GoBuildArgs {
pub mut:
	url string // e.g.  https://github.com/valeriansaliou/sonic
	pull  bool
	reset bool
	buildcmd string = 'go run build.go '
	copycmd string = ''
	name  string
}

// do a build of a go package .
// will get the code, pull and/or reset .
// will the pull all dependencies .
// will do the build
// DEBUG TRICK: put debug flag on, which will not execute the build cmd .
//    you can go to /tmp/build/buildname and do shell.sh to debug
pub fn (mut r DockerBuilderRecipe) add_gobuild_from_code(args GoBuildArgs) ! {

	r.add_codeget(url:args.url,name:args.name,reset:args.reset,pull:args.pull)!

	if args.name==""{
		return error("name needs to be specified.")
	}

	r.add_run(
		cmd: '
		cd /code/${args.name}	
		${args.buildcmd}
		${args.copycmd}
		'
	)!

}

[params]
pub struct GoPackageArgs {
pub mut:
	name string // can be comma separated, can also be url e.g. github.com/caddyserver/xcaddy/cmd/xcaddy@latest
	postcmd string //normally empty
}

//install go components
pub fn (mut r DockerBuilderRecipe) add_go_package(args GoPackageArgs) ! {

	if args.name == ''  {
		return error('name cannot be empty, name can be comma separated')
	}
	mut names:=[]string{}
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
			go install ${name}
			${args.postcmd}
			')!
	}

}