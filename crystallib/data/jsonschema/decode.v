module jsonschema

import json
import x.json2 { Any }
import os
import freeflowuniverse.crystallib.core.pathlib

fn decode(data string) !Schema {
	schema_map := json2.raw_decode(data)!.as_map()
	mut schema := json.decode(Schema, data)!
	for key, value in schema_map {
		if key == 'properties' {
			schema.properties = decode_properties(value.as_map())!
		} else if key == 'additionalProperties' {
			schema.additional_properties = decode_schemaref(value.as_map())!
		}
	}
	return schema
}

fn decode_properties(data_map map[string]Any) !map[string]SchemaRef {
	mut properties := map[string]SchemaRef{}
	for key, val in data_map {
		properties[key] = decode_schemaref(val.as_map())!
	}
	return properties
}

fn decode_schemaref(data_map map[string]Any) !SchemaRef {
	if '\$ref' in data_map {
		return Reference{
			ref: data_map['\$ref'].str()
		}
	}
	return decode(data_map.str())!
}
