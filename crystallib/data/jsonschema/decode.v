module jsonschema

import json
import x.json2 { Any }
import os
import freeflowuniverse.crystallib.core.pathlib

pub fn decode(data string) !Schema {
	schema_map := json2.raw_decode(data)!.as_map()
	mut schema := json.decode(Schema, data)!
	for key, value in schema_map {
		if key == 'properties' {
			schema.properties = decode_schemaref_map(value.as_map())!
		} else if key == 'additionalProperties' {
			schema.additional_properties = decode_schemaref(value.as_map())!
		} else if key == 'items' {
			schema.items = decode_items(value)!
		}
	}
	return schema
}

pub fn decode_items(data Any) !Items {
	if data.str().starts_with('{') {
		return decode_schemaref(data.as_map())!
	}
	if !data.str().starts_with('[') {
		return error('items field must either be list of schemarefs or a schemaref')
	}

	mut items := []SchemaRef{}
	for val in data.arr() {
		items << decode_schemaref(val.as_map())!
	}
	return items
}

pub fn decode_schemaref_map(data_map map[string]Any) !map[string]SchemaRef {
	mut schemaref_map := map[string]SchemaRef{}
	for key, val in data_map {
		schemaref_map[key] = decode_schemaref(val.as_map())!
	}
	return schemaref_map
}

pub fn decode_schemaref(data_map map[string]Any) !SchemaRef {
	if '\$ref' in data_map {
		return Reference{
			ref: data_map['\$ref'].str()
		}
	}
	return decode(data_map.str())!
}
