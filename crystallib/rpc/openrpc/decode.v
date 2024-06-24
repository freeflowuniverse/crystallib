module openrpc

import json
import x.json2 { Any }
import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.jsonschema { Reference, decode_schemaref }

pub fn decode(data string) !OpenRPC {
	mut object := json.decode(OpenRPC, data) or { return error('Failed to decode json\n${err}') }
	data_map := json2.raw_decode(data)!.as_map()
	if 'components' in data_map {
		object.components = decode_components(data_map) or {
			return error('Failed to decode components\n${err}')
		}
	}

	for i, method in data_map['methods'].arr() {
		method_map := method.as_map()
		params_arr := method_map['params'].arr()
		result := if 'result' in method_map {
			method_map['result']
		} else {
			''
		}
		object.methods[i].params = params_arr.map(decode_content_descriptor_ref(it.as_map()) or {
			return error('Failed to decode params\n${err}')
		})
		object.methods[i].result = decode_content_descriptor_ref(result.as_map()) or {
			return error('Failed to decode result\n${err}')
		}
	}
	// object.methods = decode_method(data_map['methods'].as_array)!
	return object
}

// fn decode_method(data_map map[string]Any) !Method {
// 	method := Method {
// 		name: data_map['name']
// 		description: data_map['description']
// 		result: json.decode(data_map['result'])
// 	}

// 	return method
// }

// fn decode_method_param(data_map map[string]Any) !Method {
// 	method := Method {}

// 	return method
// }

fn decode_components(data_map map[string]Any) !Components {
	mut components := Components{}
	components_map := data_map['components'].as_map()

	if 'contentDescriptors' in components_map {
		descriptors_map := components_map['contentDescriptors'].as_map()
		for key, value in descriptors_map {
			descriptor := decode_content_descriptor_ref(value.as_map())!
			components.content_descriptors[key] = descriptor
		}
	}

	if 'schemas' in components_map {
		schemas_map := components_map['schemas'].as_map()
		for key, value in schemas_map {
			schema := jsonschema.decode(value.str())!
			components.schemas[key] = schema
		}
	}

	return components
}

fn decode_content_descriptor_ref(data_map map[string]Any) !ContentDescriptorRef {
	if '\$ref' in data_map {
		return Reference{
			ref: data_map['\$ref'].str()
		}
	}
	mut descriptor := json.decode(ContentDescriptor, data_map.str())!
	descriptor.schema = decode_schemaref(data_map['schema'].as_map())!
	return descriptor
}
