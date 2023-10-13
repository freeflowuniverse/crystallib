module actorgenerator

import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import freeflowuniverse.crystallib.core.pathlib
import os

pub struct GenerateActorParams {
	model_path string
}

pub fn (generator ActorGenerator) generate_actor_struct(root_structs []codemodel.Struct) codemodel.Struct {
	return codemodel.Struct{
		name: '${generator.model_name.title()}Actor'
		fields: root_structs.map(codemodel.StructField{
			name: '${it.name.to_lower()}_map'
			typ: codemodel.Type{
				symbol: 'map[string]&${it.name}'
			}
		})
	}
}
