module openrpc

import freeflowuniverse.crystallib.core.codemodel { CodeItem }
import freeflowuniverse.crystallib.data.jsonschema { Schema }
import freeflowuniverse.crystallib.core.texttools

// generate_structs geenrates struct codes for schemas defined in an openrpc document
pub fn (o OpenRPC) generate_model() ![]CodeItem {
	components := o.components or { return []CodeItem{} }
	mut structs := []CodeItem{}
	for key, schema_ in components.schemas {
		if schema_ is Schema {
			mut schema := schema_
			if schema.title == '' {
				schema.title = texttools.name_fix_snake_to_pascal(key)
			}
			structs << schema.to_code()!
		}
	}
	return structs
}

// //
// pub fn (s Schema) to_struct() codemodel.Struct {
// 	mut attributes := []Attribute{}
// 	if c.depracated {
// 		attributes << Attribute {name: 'deprecated'}
// 	}
// 	if !c.required {
// 		attributes << Attribute {name: 'params'}
// 	}

// 	return codemodel.Struct {
// 		name: name
// 		description: summary
// 		required: required
// 		schema: Schema {

// 		}
// 		attrs: attributes
// 	}
// }
