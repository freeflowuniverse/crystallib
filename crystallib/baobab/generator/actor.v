module generator

import freeflowuniverse.crystallib.core.codemodel { CodeFile, CodeItem, File, Function, Import, Module, Struct }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements { Header }
import freeflowuniverse.crystallib.core.pathlib
import os
import json

fn get_children(s Struct, code []CodeItem) []Struct {
	structs := code.filter(it is Struct).map(it as Struct)
	mut children := []Struct{}
	for structure in structs {
		if s.fields.any(it.typ.symbol == structure.name) {
			children << structure
			children << get_children(structure, code)
		}
	}

	return children
}

pub fn generate_actor(name string, object_names []string, code []CodeItem) !Actor {
	mut objects := []BaseObject{}
	for s_ in code.filter(it is Struct).map(it as Struct).filter(texttools.name_fix(it.name) in object_names.map(texttools.name_fix(it))) {
		mut s := s_ as Struct
		s.mod = 'tftc.baobab.models.${s.mod}'
		objects << BaseObject{
			structure: s
			methods: code.filter(it is Function).map(it as Function).filter(it.receiver.typ.symbol == s.name).map(it as Function)
			children: get_children(s, code)
		}
	}

	mut actor := Actor{
		name: name
		objects: objects
		// mod: generate_actor_module(name, objects)!
	}
	actor.structure = generate_actor_struct(name)
	actor.methods = actor.generate_methods()!
	return actor
}

pub fn (actor Actor) generate_methods() ![]ActorMethod {
	mut methods := []ActorMethod{}
	for object in actor.objects {
		methods << [
			ActorMethod{
				name: object.structure.name
				func: generate_new_method(actor.structure, object)
			},
			ActorMethod{
				name: object.structure.name
				func: generate_get_method(actor.structure, object)
			},
			ActorMethod{
				name: object.structure.name
				func: generate_set_method(actor.structure, object)
			},
			ActorMethod{
				name: object.structure.name
				func: generate_delete_method(actor.structure, object)
			},
			ActorMethod{
				name: object.structure.name
				func: generate_list_method(actor.structure, object)
			},
		]
	}
	return methods
}

pub struct ActorConfig {
pub mut:
	name string
}

pub fn parse_actor(path string) !Actor {
	code := codeparser.parse_v(path, recursive: true)!
	mut config := parse_config('${path}/config.json')!

	mut methods := []ActorMethod{}
	for s in code.filter(it is Function).map(it as Function).filter(it.receiver.name == config.name) {
		methods << ActorMethod{
			func: s
		}
	}
	mut actor := Actor{}
	actor.methods = methods
	actor.structure = generate_actor_struct(actor.name)

	return actor
}

pub fn parse_config(path string) !ActorConfig {
	mut config_file := pathlib.get_file(path: path)!
	actor := json.decode(ActorConfig, config_file.read()!)!
	return actor
}

pub fn parse_readme(path string) !Actor {
	readme := markdownparser.new(path: '${path}/README.md')!
	name_header := readme.children()[1] as Header
	name := name_header.content
	return Actor{
		name: name
	}
}

pub fn (a Actor) generate_module() !Module {
	actor_struct := generate_actor_struct(a.name)

	readme := File{
		name: 'README'
		extension: 'md'
		content: '# ${a.name}\n${a.description}'
	}
	mut files := [
		generate_factory_file(a.name),
	]
	// files << a.generate_model_files()!

	// generate code files for each of the objects the actor is responsible for
	for object in a.objects {
		files << generate_object_code(actor_struct, object)
		files << generate_object_test_code(actor_struct, object)!
	}

	return Module{
		name: a.name
		files: files
		misc_files: [readme]
	}
}

pub fn (a Actor) generate_openrpc_specification() !File {
	openrpc_obj := a.generate_openrpc()
	openrpc_json := openrpc_obj.encode()!

	openrpc_file := File{
		name: 'openrpc'
		extension: 'json'
		content: openrpc_json
	}

	// sshrpc_files(a)!
	// files << openrpc_files.map(CodeFile{...it, name: 'openrpc_${it.name}'})
	return openrpc_file
}

pub fn (a Actor) generate_model_files() ![]CodeFile {
	structs := a.objects.map(it.structure)
	return a.objects.map(codemodel.new_file(
		mod: texttools.name_fix(a.name)
		name: '${texttools.name_fix(it.structure.name)}_model'
		// imports: [Import{mod:'freeflowuniverse.crystallib.baobab.actor'}]
		items: [it.structure]
	))
}

pub fn generate_actor_module(name string, objects []BaseObject) !Module {
	actor := generate_actor_struct(name)
	mut files := [generate_factory_file(name)]

	// generate code files for each of the objects the actor is responsible for
	for object in objects {
		files << generate_object_code(actor, object)
		files << generate_object_test_code(actor, object)!
	}
	return Module{
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
		imports: [Import{
			mod: 'freeflowuniverse.crystallib.baobab.actor'
		}]
		items: [actor_struct, actor_factory]
	)
}

pub fn generate_actor_struct(name string) Struct {
	return Struct{
		is_pub: true
		name: '${name.title()}'
		embeds: [Struct{
			name: 'actor.Actor'
		}]
	}
}

// generate_actor_factory generates the factory function for an actor
pub fn generate_actor_factory(actor Struct) Function {
	mut function := codemodel.parse_function('pub fn get(config actor.ActorConfig) !${actor.name}') or {
		panic(err)
	}
	function.body = 'return ${actor.name}{Actor: actor.new(config)!}'
	return function
}
