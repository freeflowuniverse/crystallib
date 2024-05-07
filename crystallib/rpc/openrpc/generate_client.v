module openrpc

import freeflowuniverse.crystallib.core.codemodel {Struct, Function, CodeItem, Attribute, CodeFile}
import freeflowuniverse.crystallib.data.jsonschema { Reference, SchemaRef }
import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.core.texttools



// generate_structs geenrates struct codes for schemas defined in an openrpc document
pub fn (o OpenRPC) generate_client_file() !CodeFile {
	name := texttools.name_fix(o.info.title)
	client_struct := jsonrpc.generate_client_struct(name)
	
	mut code := []CodeItem{}
	code << client_struct
	code << jsonrpc.generate_ws_factory_code(name)
	methods := jsonrpc.generate_client_methods(client_struct, o.methods.map(Function{name: it.name}))!
	println('methods ${methods}')

	code << methods.map(CodeItem(it))
	return CodeFile {
		name: 'client'
		mod: name
		imports: []
		items: code
	}
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