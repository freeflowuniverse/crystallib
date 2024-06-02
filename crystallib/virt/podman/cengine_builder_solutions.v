module podman

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console


@[params]
pub struct GetArgs {
	reset bool
}


// builder machine based on arch and install vlang
pub fn (mut e CEngine) builder_base(args GetArgs) !Builder {
	name := "base"
	if !args.reset && e.builder_exists(name)! {
		return e.builder_get(name)!
	}
	console.print_header('buildah base build')
	mut builder := e.builder_new(name: name, from: 'scratch', delete:true)!
	mount_path := builder.mount_to_path()!
	osal.exec(
		cmd: 'pacstrap -c ${mount_path} base screen bash coreutils curl mc unzip sudo which openssh'
	)!
	//builder.set_entrypoint('redis-server')!
	builder.commit('localhost/${name}')!
	return builder
}


// builder machine based on arch and install vlang
pub fn (mut e CEngine) builder_go_rust(args GetArgs) !Builder {
	console.print_header('buildah builder go rust')
	name := "builder_go_rust"
	e.builder_base(reset:false)!
	if !args.reset && e.builder_exists(name)! {
		return e.builder_get(name)!
	}		
	mut builder := e.builder_new(name: name, from: 'localhost/base', delete: true)!
	builder.hero_execute_cmd("installers -n golang,rust")!
	builder.clean()!
	builder.commit('localhost/${name}')!
	e.load()!
	return builder
}

pub fn (mut e CEngine) builder_js(args GetArgs) !Builder {
	console.print_header('buildah builder js')
	name := "builder_js"
	e.builder_base(reset:false)!
	if !args.reset && e.builder_exists(name)! {
		return e.builder_get(name)!
	}		
	mut builder := e.builder_new(name: name, from: 'localhost/base', delete: true)!
	builder.hero_execute_cmd("installers -n nodejs")!
	builder.clean()!
	builder.commit('localhost/${name}')!
	e.load()!
	return builder
}

pub fn (mut e CEngine) builder_js_python(args GetArgs) !Builder {
	console.print_header('buildah builder js python')
	name := "builder_js_python"
	e.builder_js(reset:false)!
	if !args.reset && e.builder_exists(name)! {
		return e.builder_get(name)!
	}		
	mut builder := e.builder_new(name: name, from: 'localhost/builder_js', delete: true)!
	builder.hero_execute_cmd("installers -n python")!
	builder.clean()!
	builder.commit('localhost/${name}')!
	e.load()!
	return builder
}

pub fn (mut e CEngine) builder_crystal(args GetArgs) !Builder {
	console.print_header('buildah builder crystal dev')
	name := "builder_crystal"
	e.builder_js_python(reset:false)!
	if !args.reset && e.builder_exists(name)! {
		return e.builder_get(name)!
	}		
	mut builder := e.builder_new(name: name, from: 'localhost/builder_js_python', delete: true)!
	builder.hero_execute_cmd("installers -n python")!
	builder.clean()!
	builder.commit('localhost/${name}')!
	e.load()!
	return builder
}



// // builder machine based on arch and install vlang
// pub fn (mut e CEngine) builder_js() ! {
// 	name := "base_js"
// 	mut builder := e.builder_new(name: 'base', from: 'base')!
// 	mount_path := builder.mount_to_path()!
// 	osal.exec(
// 		cmd: 'pacstrap -c ${mount_path} base bash coreutils curl mc unzip sudo which openssh'
// 	)!
// 	builder.clean()!
// 	//builder.set_entrypoint('redis-server')!
// 	builder.commit('localhost/builderjs')!
// }

// @[params]
// pub struct CrystalBuildArgs {
// 	crystal_branch string = 'development'
// }

// // create the base builder, and install crystallib on it
// pub fn (mut engine CEngine) builderv_create(args CrystalBuildArgs) !Builder {
// 	// println(engine.builders()!)
// 	// println(engine.bimages()!)
// 	if !engine.image_exists(repo: 'localhost/builder')! {
// 		engine.builder_create()!
// 	}

// 	mut builder := engine.builder_new(name: 'builderv', from: 'localhost/builder', delete: true)!
// 	console.print_debug('build V & crystal')
// 	// mount_path := builder.mount_to_path()!
// 	// console.print_debug("mountpath: ${mount_path}")
// 	// install v and crystallib
// 	builder.run(
// 		cmd: '
// 			curl -fsSL https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/install_hero.sh -o /tmp/install.sh
// 			bash /tmp/install.sh
// 			'
// 	)!

// 	// builder.run(
// 	// 	cmd: '
// 	// 		cd /root/code/github/freeflowuniverse/crystallib
// 	// 		git reset --hard
// 	// 		git checkout -B ${args.crystal_branch}
// 	// 		git fetch --all
// 	// 		git reset --hard origin/${args.crystal_branch}

// 	// 		/root/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh
// 	// 		'
// 	// )!	

// 	builder.clean()!
// 	builder.commit('localhost/builderv')!
// 	// builder.delete()!

// 	return builder
// }

// pub fn (mut engine CEngine) hero_build(args HeroBuildArgs) ! {

// 	mut builder := engine.builder_new(name: "builder", from: 'localhost/builder', delete:true)!
// 	mount_path := builder.mount_to_path()!
// 	builder.run("mkdir -p /var/builder/bin/hero", false)!
// 	cmd:="cd /root/code/github/freeflowuniverse/crystallib && git reset --hard && git checkout -B ${args.crystal_branch} && git fetch --all && git reset --hard origin/${args.crystal_branch}"
// 	builder.run(cmd, false)!
// 	builder.run("/root/code/github/freeflowuniverse/crystallib/cli/hero/compile_debug.sh", false)!

// 	console.print_debug(mount_path)

// }

// // create the base builder, and install crystallib on it
// pub fn (mut engine CEngine) builder_(args CrystalBuildArgs) !Builder {
// 	// println(engine.builders()!)
// 	// println(engine.bimages()!)
// 	if !engine.image_exists(repo: 'localhost/builder')! {
// 		engine.builder_create()!
// 	}

// 	mut builder := engine.builder_new(name: 'builderv', from: 'localhost/builder', delete: true)!
// 	console.print_debug('build V & crystal for ')
// 	// mount_path := builder.mount_to_path()!
// 	// console.print_debug("mountpath: ${mount_path}")
// 	// install v and crystallib
// 	builder.run(
// 		cmd: '
			
// 			'
// 	)!

// 	// builder.copy('/usr/local/bin/hero', '/var/builder/bin/hero/')!
// 	builder.commit('localhost/builderv')!
// 	// builder.delete()!

// 	return builder
// }

