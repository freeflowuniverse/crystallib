module actorgenerator

import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.pathlib
import os

fn test_generate_actor_struct() {
	generator := ActorGenerator{
		model_name: 'test'
	}

	test_root_structs := [
		codemodel.Struct{
			name: 'RootStruct'
		},
	]

	actor_struct := generator.generate_actor_struct(test_root_structs)
	println(actor_struct.vgen())
	panic('sh')
}
