module openrpc

import json
import x.json2 { Any }
import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.jsonschema { Reference, decode_schemaref }

fn decode(data string) !OpenRPC {
	mut object := json.decode(OpenRPC, data)!
	data_map := json2.raw_decode(data)!.as_map()
	if 'components' in data_map { 
		object.components = decode_components(data_map)!
	}

	return object
}

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
