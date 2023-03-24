module docker

pub fn (mut r DockerBuilderRecipe) add_zinit() ! {
	r.add_run(
		cmd: '
		apk add wget
    	wget https://github.com/threefoldtech/zinit/releases/download/v0.2.5/zinit -O /sbin/zinit
    	chmod +x /sbin/zinit
		touch /etc/environment
		mkdir -p /etc/zinit/
	'
	)!

	r.add_entrypoint(cmd: '/sbin/zinit init --container')!
}

[params]
pub struct ExecuteArgs {
pub mut:
	source string // is the filename, needs to be embedded
	debug  bool
}

// execute the file as embedded
pub fn (mut r DockerBuilderRecipe) execute(args ExecuteArgs) ! {
	if args.source == '' {
		return error('source cant be empty, \n ${r}')
	}
	path := args.source
	r.add_file(source: path, dest: '/tmp/${path}', make_executable: true)!
	if !args.debug {
		r.add_run(cmd: '/tmp/${path}')!
	}
}

pub fn (mut r DockerBuilderRecipe) add_gobuilder() ! {
	r.add_package(name: 'musl-dev,gcc, g++, go')!
	r.add_env(env: 'GOPATH=/app')!
	r.add_workdir(workdir: '/app')!
}

pub fn (mut r DockerBuilderRecipe) add_nodejsbuilder() ! {
	r.add_package(name: 'nodejs, npm')!
}

pub fn (mut r DockerBuilderRecipe) add_vbuilder() ! {
	r.add_package(name: 'git, musl-dev, clang, gcc, openssh-client, make')!
	r.add_run(
		cmd: "
		git clone --depth 1 https://github.com/vlang/v /opt/vlang 
		cd  /opt/vlang
		make VFLAGS='-cc gcc' 
		./v -version 
		./v symlink
	"
	)!
	r.add_workdir(workdir: '/opt/vlang')!
}

[params]
pub struct CodeGetArgs {
pub mut:
	url string
}

pub fn (mut r CodeGetArgs) add_codeget() ! {
	// r.add_run(cmd:'
	// 	git clone --depth 1 https://github.com/vlang/v /opt/vlang
	// 	cd  /opt/vlang
	// 	make VFLAGS=\'-cc gcc\'
	// 	./v -version
	// 	./v symlink
	// ')!
}
