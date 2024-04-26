module jsonrpc

import freeflowuniverse.crystallib.core.codemodel
import freeflowuniverse.crystallib.core.codeparser
import os
import freeflowuniverse.crystallib.core.pathlib

@[params]
pub struct ServerGenConfig {
	title         string   // Title of the JSON-RPC API
	description   string   // Description of the JSON-RPC API
	version       string = '1.0.0' // OpenRPC Version used
	source        string   // Source code directory to generate doc from
	strict        bool     // Strict mode generates document for only methods and struct with the attribute `openrpc`
	exclude_dirs  []string // directories to be excluded when parsing source for document generation
	exclude_files []string // files to be excluded when parsing source for document generation
	only_pub      bool     // excludes all non-public declarations from document generation
	destination   string   // Destination path for where the generated server code will be written to
}

// docgen returns OpenRPC Document struct for JSON-RPC API defined in the config params.
// returns generated OpenRPC struct which can be encoded into json using `openrpc.OpenRPC.encode()`
pub fn servergen(config ServerGenConfig) ! {
	$if debug {
		eprintln('Generating OpenRPC Document from path: ${config.source}')
	}

	// parse source code into code items
	code := codeparser.parse_v(config.source,
		exclude_dirs: config.exclude_dirs
		exclude_files: config.exclude_files
		only_pub: config.only_pub
		recursive: true
	)!

	server_code := generate_server(code)

	mut path_ := pathlib.get_dir(
		path: config.destination
		create: true
	)!
	mut dest_path := path_.path + '/openrpc_server.v'
	// if target == '.' {
	// 	target_path = os.getwd() + '/openrpc.json'
	// }

	os.write_file(dest_path, server_code)!
}

pub fn generate_server(code []codemodel.CodeItem) string {
	imports := generate_imports(code)
	functions := code.filter(it is codemodel.Function).map(it as codemodel.Function)
	handlers := functions.map(generate_handler(it)).join('\n')
	states := functions.filter(it.receiver.name != '').map(it.receiver)
	registers := functions.map(generate_register_call(it)).join_lines()
	return $tmpl('templates/server.v.template')
}

pub fn generate_imports(code []codemodel.CodeItem) string {
	mut imports := map[string]codemodel.Import{}
	for item in code {
		if item is codemodel.Struct {
			if imports.keys().contains(item.mod) {
				imports[item.mod].types << item.name
			} else {
				imports[item.mod].mod = item.mod
				imports[item.mod].types = [item.name]
			}
		} else if item is codemodel.Function {
			if imports.keys().contains(item.mod) {
				imports[item.mod].types << item.name
			} else {
				imports[item.mod].mod = item.mod
				imports[item.mod].types = [item.name]
			}
		}
	}
	return imports.values().map(it.vgen()).join_lines()
}

pub fn generate_handler(function codemodel.Function) string {
	if function.receiver.name != '' {
		fn_call := if function.result.name != '' {
			'result := receiver.${function.name}'
		} else {
			'receiver.${function.name}'
		}
		return $tmpl('templates/handler_method.v.template')
	} else {
		return $tmpl('templates/handler.v.template')
	}
	handler_function := codemodel.Function{
		name: '${function.name}_handler'
		params: [
			codemodel.Param{
				name: 'ctx'
				mutable: true
				typ: codemodel.Type{
					symbol: 'Context'
				}
			},
		]
		result: codemodel.Result{
			typ: codemodel.Type{
				symbol: 'name'
			}
		}
	}

	return $tmpl('templates/handler.v.template')
}

pub fn generate_register_call(function codemodel.Function) string {
	return if function.receiver.name != '' {
		'handler.register(\'${function.name}\', handler.${function.name}_handle)!'
	} else {
		'handler.register(${function.name}, ${function.name}_handle)!'
	}
}
