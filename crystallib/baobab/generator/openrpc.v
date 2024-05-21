module generator

import freeflowuniverse.crystallib.core.codemodel {Module,File, StructField, Import,Param,Struct CodeFile, CustomCode, Function, CodeItem, Type}
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.rpc.openrpc {OpenRPC, Components}
import freeflowuniverse.crystallib.data.jsonschema {SchemaRef}

// @[params]
// pub struct GenerateOpenRPCConfig {
// 	openrpc_path // path of where the openrpc document will be written
// }

pub fn generate_openrpc_files(actor Actor) ![]CodeFile {
	openrpc_obj := generator.generate_openrpc(actor)
	openrpc_json := openrpc_obj.encode()!
	
	openrpc_file := File {
		name: 'openrpc'
		extension: 'json'
		content: openrpc_json
	}

	mut methods_map := map[string]Function
	for method in actor.methods {
		methods_map[method.func.name] = method.func
	}

	mut objects_map := map[string]Struct
	for object in actor.objects {
		objects_map[object.structure.name] = object.structure
	}
	actor_struct := generator.generate_actor_struct(actor.name)

	client_file := openrpc_obj.generate_client_file(objects_map)!	
	client_test_file := openrpc_obj.generate_client_test_file(methods_map)!

	handler_file := openrpc_obj.generate_handler_file(actor_struct, methods_map, objects_map)!	
	handler_test_file := openrpc_obj.generate_handler_test_file(actor_struct, methods_map, objects_map)!	

	server_file := openrpc_obj.generate_server_file()!	
	server_test_file := openrpc_obj.generate_server_test_file()!	

	return [
		client_file,
		client_test_file,
		handler_file,
		handler_test_file,
		server_file,
		server_test_file,
	]
	// misc_files: [openrpc_file]
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
		methods: actor.methods.map(openrpc.fn_to_method(it.func))
		components: Components { 
			schemas: schemas
		}
	}
}

pub fn (mut a Actor) export_playground(path string, openrpc_path string) ! {
	dollar := '$'
	openrpc.export_playground(dest: pathlib.get_dir(path:'${path}/playground')!, specs:[pathlib.get(openrpc_path)])!
	mut cli_file := pathlib.get_file(path:'${path}/command/cli.v')!
	cli_file.write($tmpl('./templates/playground.v.template'))!
}

pub fn (mut a Actor) export_command(path string) ! {
	dollar := '$'
	name := texttools.name_fix_pascal_to_snake(a.name)
	cmd_dir := pathlib.get_dir(path:'${path}/command')!
	mut cli_file := pathlib.get_file(path:'${path}/command/cli.v')!
	cli_file.write($tmpl('./templates/cli.v.template'))!
}

// pub fn  function_to_method()

// pub fn param_to_content_descriptor(param Param) openrpc.ContentDescriptor {
// 	if param.name == 'id' && param.typ.symbol == 
	
// 	return openrpc.ContentDescriptor {
// 		name: param.name
// 		summary: param.description
// 		required: param.is_required()
// 		schema: 
// 	}
// }