#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.baobab.generator
import freeflowuniverse.crystallib.core.codemodel {Function, Struct}
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.pathlib
import os

const actors_dir = '${os.dir(os.dir(@FILE))}/actors'


// a map of each actor with the base objects they are responsible of
const actor_object_map = {
	'accountant': ['Budget'],
	'coordinator': ['Story'],
	'scheduler': ['Calendar', 'Event']
}

mut seed_dir := pathlib.get_dir(path: os.dir(@FILE))!
mut dir_list := seed_dir.list()!

code := codeparser.parse_v(seed_dir.path, recursive: true)!
structs := code.map(it as Struct)

for name, objects in actor_object_map {
	actor_objects := structs.filter(it.name in objects)
	actor_module := generator.generate_actor_module(name, actor_objects) or {
		println('Failed to generate actor ${name}\n${err}')
		continue
	}
	actor_module.write_v('${actors_dir}', format: true, overwrite: true) or {
		println('Failed to generate actor ${name}\n${err}')
		continue
	}

	actor := generator.generate_actor(name, actor_objects) or {
		println('Failed to generate actor ${name}\n${err}')
		continue
	}

	openrpc_module := generator.generate_openrpc_module(actor)!

	openrpc_path := '${actors_dir}/${name}/openrpc'
	openrpc_module.write_v(openrpc_path, format: true)!
}