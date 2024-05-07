module openrpc

import freeflowuniverse.crystallib.core.codemodel {CodeItem, CodeFile, Function, Struct}
import freeflowuniverse.crystallib.rpc.jsonrpc
import freeflowuniverse.crystallib.core.texttools

pub fn (o OpenRPC) generate_handler_file(receiver Struct, method_map map[string]Function) !CodeFile {
	name := texttools.name_fix(o.info.title)
	
	mut code := []CodeItem{}
	// code << client_struct
	// code << jsonrpc.generate_ws_factory_code(name)

	// methods := jsonrpc.generate_client_methods(client_struct, o.methods.map(Function{name: it.name}))!
	// code << methods.map(CodeItem(it))
	
	return CodeFile {
		name: 'handler'
		mod: name
		imports: []
		items: jsonrpc.generate_handler(
			methods: method_map.values()
			receiver: receiver
		)!
	}
}

// pub fn ()