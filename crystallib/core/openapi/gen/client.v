module gen

// import net.http
// import freeflowuniverse.crystallib.core.openapi
// import freeflowuniverse.crystallib.core.codemodel

// [params]
// pub struct ClientMethodConfig {
// 	receiver   codemodel.Param
// 	name       string // name of method
// 	parameters []Parameter
// 	responses  map[string]Parameter // Params mapped by http response code
// 	method     http.Method
// }

// pub struct Parameter {
// 	codemodel.Param
// 	encoding ParameterEncoding
// }

// pub enum ParameterEncoding {
// 	path
// }

// pub struct ClientCall {
// 	param_structs []codemode.Struct // structures of the params of the client call
// 	call_method codemodel.Function // function of the client call method
// 	result_structs []codemodel.Struct // structures of the result of the client call
// }

// // generate_client_call generates a client method and accompanying necessary
// pub fn generate_client_call(config ClientMethodConfig) !codemodel.Function {

// 	params_structs := generate_structs(config.parameters)
// 	method := generate_client_method(config)
// }

// pub fn generate_client_call_params(config ) {
// }

// // generate_client_call generates a client method and accompanying necessary
// pub fn generate_client_method(config ClientMethodConfig) !codemodel.Function {
// 	// http_request :=

// 	if '200' !in config.responses {
// 		return error('At least one response should have a 200 http code')
// 	}

// 	result_struct := config.responses['200'].struct_

// 	result := codemodel.Result{
// 		name: result_struct.name
// 		structure: config.responses['200'].Param.struct_
// 		typ: result_struct.name
// 	}

// 	return codemodel.Function{
// 		name: config.name
// 		receiver: config.receiver
// 		params: config.parameters.map(it.Param)
// 		result: config.result
// 	}
// }

// fn schema_to_struct() {
// }
