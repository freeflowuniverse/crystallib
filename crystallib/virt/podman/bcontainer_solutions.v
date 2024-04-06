
module podman
import freeflowuniverse.crystallib.osal

//builder machine based on arch and install vlang
pub fn (mut e CEngine) builder_get() ! {

	//todo: check if builder already exists
	e.builder_new()!
}

//create a builder from scratch
pub fn (mut engine CEngine) builder_new() ! {

	mut builder := engine.bcontainer_new(name: "builder", from: 'scratch')!

	mount_path := builder.mount_to_path()!
	osal.exec(
		cmd: 'pacstrap -c ${mount_path} base bash coreutils vim curl mc unzip vim sudo which openssh fuse2'
	)!
	// install v and crystallib
	builder.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh -o /tmp/install.sh',
		false)!
	builder.run('bash /tmp/install.sh', false)!
	// install hero
	// builder.run('curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh -o installer_hero.sh',
	// 	false)!
	// builder.run('bash installer_hero.sh"', false)!		
	builder.run('bash -c "redis-server --daemonize yes && bash installer_hero.sh"', false)!
	builder.set_entrypoint('redis-server')!
	builder.commit('localhost/builder')!

}