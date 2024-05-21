module generator

import freeflowuniverse.crystallib.core.codemodel {File, Module, Import, Struct,Param, CodeFile, Function, Result, Type}
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import os

pub fn generate_actor(name string, objects []Struct) !Actor {
	actor_struct := generate_actor_struct(name)
	
	return Actor {
		name: name
		objects: objects.map(BaseObject{structure: it})
		mod: generate_actor_module(name, objects)!
		methods: generate_actor_methods(actor_struct, objects)!
	}
}

pub fn generate_actor_methods(actor Struct, objects []Struct) ![]ActorMethod {
	mut methods := []ActorMethod{}
	for object in objects {
	methods << [
		ActorMethod {
			name: object.name
			func: generate_new_method(actor, object)
		},
		ActorMethod {
			name: object.name
			func: generate_get_method(actor, object)
		},
		ActorMethod {
			name: object.name
			func: generate_set_method(actor, object)
		},
		ActorMethod {
			name: object.name
			func: generate_delete_method(actor, object)
		},
		ActorMethod {
			name: object.name
			func: generate_list_method(actor, object)
		},
	]
	}
	return methods
}

pub fn (a Actor) generate_module() !Module {
	actor_struct := generate_actor_struct(a.name)
	mut files := [
		generate_factory_file(a.name)
	]
	// files << a.generate_model_files()!

	// generate code files for each of the objects the actor is responsible for
	for object in a.objects.map(it.structure) {
		files << generate_object_code(actor_struct, object)
		files << generate_object_test_code(actor_struct, object)!
	}

	openrpc_obj := generator.generate_openrpc(a)
	openrpc_json := openrpc_obj.encode()!
	
	openrpc_file := File {
		name: 'openrpc'
		extension: 'json'
		content: openrpc_json
	}

	openrpc_files := generate_openrpc_files(a)!
	files << openrpc_files.map(CodeFile{...it, name: 'openrpc_${it.name}'})

	return Module {
		name: a.name
		files: files
		misc_files: [openrpc_file]
	}
}

pub fn (a Actor) generate_model_files() ![]CodeFile {
	structs := a.objects.map(it.structure)
	return a.objects.map(
			codemodel.new_file(
			mod: texttools.name_fix(a.name)
			name: '${texttools.name_fix(it.structure.name)}_model'
			// imports: [Import{mod:'freeflowuniverse.crystallib.baobab.actor'}]
			items: [it.structure]
		)
	)
}

pub fn generate_actor_module(name string, objects []Struct) !Module {
	actor := generate_actor_struct(name)
	mut files := [generate_factory_file(name)]

	// generate code files for each of the objects the actor is responsible for
	for object in objects {
		files << generate_object_code(actor, object)
		files << generate_object_test_code(actor, object)!
	}
	return Module {
		name: name
		files: files
	}
}

pub struct GenerateActorParams {
	model_path string
}

pub fn generate_factory_file(name string) CodeFile {
	actor_struct := generate_actor_struct(name)
	actor_factory := generate_actor_factory(actor_struct)
	return codemodel.new_file(
		mod: texttools.name_fix(name)
		name: 'actor'
		imports: [Import{mod:'freeflowuniverse.crystallib.baobab.actor'}]
		items: [actor_struct, actor_factory]
	)
}

pub fn generate_actor_struct(name string) Struct {
	return codemodel.Struct{
		is_pub: true
		name: '${name.title()}'
		embeds: [Struct{name:'actor.Actor'}]
	}
}

// generate_actor_factory generates the factory function for an actor
pub fn generate_actor_factory(actor Struct) Function {
	mut function := codemodel.parse_function('pub fn get(config actor.ActorConfig) !${actor.name}') or {panic(err)}
	function.body = 'return ${actor.name}{Actor: actor.new(config)!}'
	return function
}
