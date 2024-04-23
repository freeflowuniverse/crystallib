module jsonrpc

import freeflowuniverse.crystallib.core.codemodel {CodeItem, Result, Param, Attribute, Type, StructField, Function, Module, CodeFile, Struct}

pub struct GenerateClientConfig {
	name string
	methods []Function
}

pub fn generate_client(config GenerateClientConfig) Module {
	factory_file := generate_client_factory(config.name)
	return Module{
		files:[
			factory_file
		]
	}
} 

// generate_client_factory generates a factory code file with factory functions for the client
pub fn generate_client_factory(name string) CodeFile {
	mut code := []CodeItem{}
	code << generate_client_struct(name)
	code << generate_ws_factory_code(name)
	
	return CodeFile {
		mod: name
		imports: []
		items: code
	}
}

pub fn generate_client_struct(name string) Struct {
	return Struct {
		is_pub: true
		name: name
		fields: [
			StructField{
				name: 'transport'
				typ: Type{ symbol: 'jsonrpc.IRpcTransportClient'}
				is_ref: true
			}
		]
	}
}

pub fn generate_ws_factory_code(name string) []CodeItem {
	ws_factory_param := Struct {
		name: 'WsClientConfig'
		attrs: [Attribute{name: 'params'}]
		fields: [
			StructField{
				name: 'address'
				typ:Type{symbol:'string'}
			},
			StructField{
				name: 'logger'
				typ:Type{symbol:'log.Logger'}
			}
		]
	}

	ws_factory_function := Function {
		is_pub: true
		name: 'new_ws_client'
		params: [
			Param{
				name: 'config'
				typ: Type{symbol:'WsClientConfig'}
			}
		]
		body: 'mut transport := rpcwebsocket.new_rpcwsclient(config.address, config.logger)!
	spawn transport.run()
	return @{client_name} {
		transport: transport
	}'
		result: Result{
			result: true
			typ: Type{symbol: name}
		}
	}
	return [ws_factory_param, ws_factory_function]
}

pub fn generate_client_methods(client_struct Struct, methods []Function) ![]Function {
	return methods.map(generate_client_method(client_struct, it)!)
}

/*
pub fn (mut client PetstoreJsonRpcClient) get_pet(name string) !Pet {
	request := jsonrpc.new_jsonrpcrequest[string]('get_pet', name)
	response := client.transport.send(request.to_json(), 6000)!
	return json.decode(Pet, response)!
}
*/
pub fn generate_client_method(client_struct Struct, method Function) !Function {
	if method.params.len > 1 { return error('json rpc calls with more than 1 param are not supported')}

	request_stmt := if method.params.len == 0 {
		"request := jsonrpc.new_jsonrpcrequest[string]('${method.name}', '')"
	} else {
		"request := jsonrpc.new_jsonrpcrequest[${method.params[0].typ.symbol}]('${method.name}', ${method.params[0].name})"
	}

	return_stmt := if method.result.typ.symbol == '' {
		'_ := client.transport.send(request.to_json(), 6000)!'
	} else {
		'response := client.transport.send(request.to_json(), 6000)!
		return json.decode(${method.result.typ.symbol}, response)!"
		'
	}

	return Function {
		...method
		receiver: Param {
			name: 'client'
			typ: Type{symbol:client_struct.name}
		}
		result: Result {
			optional: true
		}
		body: "${request_stmt}\n${return_stmt}"
	}
}