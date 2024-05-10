module generator

import freeflowuniverse.crystallib.core.codemodel {Module, Import, Struct,Param, CodeFile, Function, Result, Type}
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import os

pub fn generate_actor(name string, objects []Struct) !Actor {
	actor_struct := generate_actor_struct(name)
	
	return Actor {
		name: name
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

// pub fn get(config actor.ActorConfig) !ExampleActor {
// 	return ExampleActor{
// 		Actor: actor.new(config)!
// 	}
// }
pub fn generate_actor_factory(actor Struct) Function {
	return Function{
		is_pub: true
		params: [Param{name: 'config', typ:Type{symbol:'actor.ActorConfig'}}]
		result: Result{
			typ:Type{
				symbol:actor.name
				is_optional: true
			}
			result: true
		}
		name: 'get'
		body: 'return ${actor.name}{\nActor: actor.new(config)!\n}'
	}
}
