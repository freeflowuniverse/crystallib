module gen

import net.http
import freeflowuniverse.crystallib.core.codemodel { CodeFile, CodeItem, Struct, Type }

pub struct ClientGenerator {
	api_name      string // name of the api the client is being generated for
	client_struct Struct // the structure representing the API Client, receiver of API Call methods.
pub mut:
	generated_structs []Struct
	generated_methods []string
}

fn (mut gen ClientGenerator) generate_client() CodeFile {
	return CodeFile{
		// name: 'client'
		mod: '${gen.api_name}_client'
		imports: []
		items: [gen.client_struct]
	}
}

fn (mut gen ClientGenerator) generate_model(structs []Struct) !CodeFile {
	return CodeFile{
		// name: 'model'
		mod: '${gen.api_name}_client'
		items: structs.map(CodeItem(it))
	}
}

fn (mut gen ClientGenerator) generate_methods(paths []Path) !CodeFile {
	mut code := []CodeItem{}
	for path in paths {
		for operation in path.operations {
			structs := operation.parameters.map(it.Param.struct_)
			to_generate := structs.filter(it !in gen.generated_structs)
			code << gen.generate_method_structs(to_generate)
			code << gen.generate_client_method()!
		}
	}
	return CodeFile{
		// name: 'methods'
		items: code
	}
}

fn (mut gen ClientGenerator) generate_method_structs(structs []Struct) []Struct {
	gen.generated_structs << structs
	return structs
}

@[params]
pub struct ClientMethodConfig {
	receiver   codemodel.Param
	name       string // name of method
	parameters []Parameter
	responses  map[string]Parameter // Params mapped by http response code
	method     http.Method
}

// generate_client_call generates a client method and accompanying necessary
pub fn (mut gen ClientGenerator) generate_client_method(config ClientMethodConfig) !codemodel.Function {
	// http_request :=

	if '200' !in config.responses {
		return error('At least one response should have a 200 http code')
	}

	result_struct := config.responses['200'].struct_

	result := codemodel.Result{
		name: result_struct.name
		structure: config.responses['200'].Param.struct_
		typ: Type{
			symbol: result_struct.name
		}
	}

	return codemodel.Function{
		name: config.name
		receiver: config.receiver
		params: config.parameters.map(it.Param)
		result: result
	}
}
