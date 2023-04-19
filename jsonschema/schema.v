module jsonschema

import freeflowuniverse.crystallib.codemodel

pub fn struct_to_schema(struct_ codemodel.Struct) SchemaRef {
	mut properties := map[string]SchemaRef{}
	for field in struct_.fields {
		properties[field.name] = typesymbol_to_schema(field.typ.symbol)
	}
	
	return SchemaRef(Schema{
		title: struct_.name
		properties: properties
	})
}

// get schema_from_typesymbol receives a typesymbol, if the typesymbol belongs to a user defined struct
// it returns a reference to the schema, else it returns a schema for the typesymbol
pub fn typesymbol_to_schema(symbol_ string) SchemaRef {
	mut symbol := symbol_.trim_string_left('!')
	if symbol == '' {
		return SchemaRef(Schema{typ: 'null'})
	} else if symbol.starts_with('[]') {
		mut array_type := symbol.trim_string_left('[]')
		return SchemaRef(Schema{
			typ: 'array'
			items: typesymbol_to_schema(array_type)
		})
	} else if symbol.starts_with('map[string]') {
		mut map_type := symbol.trim_string_left('map[string]')
		return SchemaRef(Schema{
			typ: 'object'
			additional_properties: typesymbol_to_schema(map_type)
		})
	} else if symbol[0].is_capital() {
		return SchemaRef(Reference{ref: '#/components/schemas/$symbol'})
	} else {
		if symbol == 'void' {
			return SchemaRef(Schema{typ: 'null'})
		}
		if symbol == 'bool' {
			return SchemaRef(Schema{typ: 'boolean'})
		}
		if symbol == 'int' {
			return SchemaRef(Schema{typ: 'integer'})
		}
		if symbol == 'u16' {
			return SchemaRef(Schema{typ: 'integer'})
		}
		if symbol == 'u32' {
			return SchemaRef(Schema{typ: 'integer'})
		}
		if symbol == 'u64' {
			return SchemaRef(Schema{typ: 'string'})
		}
		if symbol == '!' {
			return SchemaRef(Schema{typ: 'null'})
		}
		if symbol == 'i64' {
			return SchemaRef(Schema{typ: 'string'})
		}
		return SchemaRef(Schema{typ: symbol})
	}
}


// // contains_object checks whether a schema is an object or an array of objects
// pub fn (schema Schema) contains_object() bool {
// 	if schema.typ == 'object' {
// 		return true
// 	} 
// 	if schema.typ != 'array' {
// 		return false
// 	}

// 	// schema is array with single type
// 	if schema.items is SchemaRef {
// 		items := schema.items as Schema
// 		return items.contains_object()
// 	} 

// 	// schema is array with multiple types
// 	items := schema.items as []Schema
// 	return items.map(it.contains_object()).any(!it)
// }

// // 
// pub fn (mut schema Schema) clean() {
// 	for property in schema.properties.filter(it.typ == 'objects') {
// 		schema.define(property)
// 	}
// }

// define defines a schema within the schema
// returns uri relative to base of schema
pub fn (mut schema Schema) define(key string, def_schema Schema) ! {
	if key in schema.defs.keys() {
		return error('Definition with key `$key` already exists.')
	}
	schema.defs[key] = def_schema
}


// pub fn (schema Schema) exists(id string) !bool {
// 	if false {
// 		return error('unexpected id format')
// 	}
// 	return schema.
// }

// // // https://json-schema.org/understanding-json-schema/structuring.html
// // type Identifier {
// // 	typ IDType
// // }

// // struct NonRelativeURI {
// // 	scheme string
// // 	fragment
// // }

// // enum IDType {
// // 	uri // non-relative uri
// // 	relative_reference
// // 	uri_reference
// // 	absolute_uri
// // }

// // pub fn load_id() Identifier {

// // }