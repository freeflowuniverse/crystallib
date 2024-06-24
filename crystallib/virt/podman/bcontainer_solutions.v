module podman

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console

// builder machine based on arch and install vlang
pub fn (mut e CEngine) builder_create() ! {
	mut builder := e.bcontainer_new(name: 'builder', from: 'scratch')!
	mount_path := builder.mount_to_path()!
	osal.exec(
		cmd: 'pacstrap -c ${mount_path} base bash coreutils curl mc unzip sudo which openssh go rust cargo'
	)!
	builder.set_entrypoint('redis-server')!
	builder.commit('localhost/builder')!
}

@[params]
pub struct CrystalBuildArgs {
	crystal_branch string = 'development'
}

// create the base builder, and install crystallib on it
pub fn (mut engine CEngine) builderv(args CrystalBuildArgs) !BContainer {
	// println(engine.bcontainers()!)
	// println(engine.bimages()!)
	if !engine.image_exists(repo: 'localhost/builder')! {
		engine.builder_create()!
	}

	mut builder := engine.bcontainer_new(name: 'builderv', from: 'localhost/builder', delete: true)!
	console.print_debug('build V & crystal for ')
	// mount_path := builder.mount_to_path()!
	// console.print_debug("mountpath: ${mount_path}")
	// install v and crystallib
	builder.run(
		cmd: '
			curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh -o /tmp/install.sh
			bash /tmp/install.sh
			
			cd /root/code/github/freeflowuniverse/crystallib
			git reset --hard
			git checkout -B ${args.crystal_branch}
			git fetch --all
			git reset --hard origin/${args.crystal_branch}

			/root/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh
			'
	)!

	// builder.copy('/usr/local/bin/hero', '/var/builder/bin/hero/')!
	builder.commit('localhost/builderv')!
	// builder.delete()!

	return builder
}

// pub fn (mut engine CEngine) hero_build(args HeroBuildArgs) ! {

// 	mut builder := engine.bcontainer_new(name: "builder", from: 'localhost/builder', delete:true)!
// 	mount_path := builder.mount_to_path()!
// 	builder.run("mkdir -p /var/builder/bin/hero", false)!
// 	cmd:="cd /root/code/github/freeflowuniverse/crystallib && git reset --hard && git checkout -B ${args.crystal_branch} && git fetch --all && git reset --hard origin/${args.crystal_branch}"
// 	builder.run(cmd, false)!
// 	builder.run("/root/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh", false)!

// 	console.print_debug(mount_path)

// }
