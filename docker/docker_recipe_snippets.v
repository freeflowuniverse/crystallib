module docker
import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib

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
	r.add_file_embedded(source: path, dest: '/tmp/${path}', make_executable: true)!
	if !args.debug {
		r.add_run(cmd: '/tmp/${path}')!
	}
}

pub fn (mut r DockerBuilderRecipe) add_gobuilder() ! {
	r.add_package(name: 'musl-dev,gcc, g++, go')!
	r.add_env('GOPATH','/app')!
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
	url string //e.g.  https://github.com/vlang/v
	//other example url := 'https://github.com/threefoldfoundation/www_examplesite/tree/development/manual'
	pull bool
	reset bool
	dest string //where does the directory need to be checked out to
}

//checkout a code repository on right location
pub fn (mut r DockerBuilderRecipe) add_codeget(args CodeGetArgs) ! {

	mut gs := gittools.get(root: "${r.path()}/code")!

	mut gr := gs.repo_get_from_url(url: args.url, pull: args.pull, reset: args.reset)!

	// gs.repos_print(filter: '')
	// println(gr)
	// this will show the exact path of the manual
	// println(gr.path_content_get())
	
	// mut gitaddr := gs.addr_get_from_url(url: url)!


	if args.dest.len<2{
		return error("dest is to short (min 3): now '$args.dest'")
	}

	commonpath:=pathlib.path_relative(r.path(),gr.path_content_get())!
	if commonpath.contains("..") {panic("bug should not be")}

	r.add_copy(source:commonpath, dest:args.dest)!


}

// add ssh server and init scripts (note: zinit needs to be installed)
pub fn (mut r DockerBuilderRecipe) add_sshserver(args CodeGetArgs) ! {
	r.add_package(name: "openssh-server")!
	
	r.add_zinit_cmd(
		name: "sshd-setup",
		oneshot: true,
		exec: "
			mkdir -p /run/sshd
			ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
			ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
			ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa -b 521
			ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519
		"
	)!

	r.add_zinit_cmd(
		name: "ssh-keys",
		after: "sshd-setup",
		exec: "
			mkdir -m 700 /root/.ssh
			echo \$SSH_KEY >> /root/.ssh/authorized_keys
			chmod 600 /root/.ssh/authorized_keys
		"
	)!

	r.add_zinit_cmd(name: "sshd", exec: "/usr/sbin/sshd -D -e", after: "sshd-setup")!
}
