module generator

import freeflowuniverse.crystallib.core.codemodel {Module,File, StructField, Import,Param,Struct CodeFile, CustomCode, Function, CodeItem, Type}
import freeflowuniverse.crystallib.rpc.openrpc {OpenRPC, Components}
import freeflowuniverse.crystallib.data.jsonschema {SchemaRef}

// @[params]
// pub struct GenerateOpenRPCConfig {
// 	openrpc_path // path of where the openrpc document will be written
// }

pub fn generate_openrpc_module(actor Actor) !Module {
	openrpc_obj := generator.generate_openrpc(actor)
	openrpc_json := openrpc_obj.encode()!
	
	openrpc_file := File {
		name: 'openrpc'
		extension: 'json'
		content: openrpc_json
	}

	client_file := openrpc_obj.generate_client_file()!	

	mut methods_map := map[string]Function
	for method in actor.methods {
		methods_map[method.func.name] = method.func
	}
	actor_struct := generator.generate_actor_struct(actor.name)

	handler_file := openrpc_obj.generate_handler_file(actor_struct, methods_map)!	
	handler_test_file := openrpc_obj.generate_handler_test_file(actor_struct, methods_map)!	

	return Module {
		files: [
			client_file,
			handler_file,
			handler_test_file,
		]
		misc_files: [openrpc_file]
	}
}

pub fn generate_openrpc(actor Actor) OpenRPC {
	
	mut schemas := map[string]SchemaRef{}
	for obj in actor.objects {
		schemas[obj.structure.name] = jsonschema.struct_to_schema(obj.structure)
	}
	return OpenRPC {
		info: openrpc.Info{
			title: actor.name.title()
			version: '1.0.0'
		}
		methods: actor.methods.map(
			openrpc.Method {
				name: it.func.name
				summary: it.func.description
				params: openrpc.params_to_descriptors(it.func.params)
			}
		)
		components: Components { 
			schemas: schemas
		}
	}
}

// pub fn param_to_content_descriptor(param Param) openrpc.ContentDescriptor {
// 	if param.name == 'id' && param.typ.symbol == 
	
// 	return openrpc.ContentDescriptor {
// 		name: param.name
// 		summary: param.description
// 		required: param.is_required()
// 		schema: 
// 	}
// }