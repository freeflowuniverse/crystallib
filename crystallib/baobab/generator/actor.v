module generator

import freeflowuniverse.crystallib.core.codemodel { CodeFile, Function, Import, Param, Result, Struct, Type }
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import os

pub struct GenerateActorParams {
	model_path string
}

pub fn (gen ActorGenerator) generate_actor() CodeFile {
	actor_struct := gen.generate_actor_struct()
	actor_factory := gen.generate_actor_factory(actor_struct)
	return codemodel.new_file(
		mod: texttools.name_fix(gen.model_name)
		name: 'actor'
		imports: [Import{
			mod: 'freeflowuniverse.crystallib.baobab.actor'
		}]
		items: [actor_struct, actor_factory]
	)
}

pub fn (gen ActorGenerator) generate_actor_struct() Struct {
	return Struct{
		is_pub: true
		name: '${gen.model_name.title()}'
		embeds: [Struct{
			name: 'actor.Actor'
		}]
	}
}

// pub fn get(config actor.ActorConfig) !ExampleActor {
// 	return ExampleActor{
// 		Actor: actor.new(config)!
// 	}
// }
pub fn (gen ActorGenerator) generate_actor_factory(actor Struct) Function {
	return Function{
		is_pub: true
		params: [
			Param{
				name: 'config'
				typ: Type{
					symbol: 'actor.ActorConfig'
				}
			},
		]
		result: Result{
			typ: Type{
				symbol: actor.name
				is_optional: true
			}
			result: true
		}
		name: 'get'
		body: 'return ${actor.name}{\nActor: actor.new(config)!\n}'
	}
}
