module jsonschema

import freeflowuniverse.crystallib.codemodel

// struct_to_schema generates a json schema or reference from a struct model
pub fn struct_to_schema(struct_ codemodel.Struct) SchemaRef {
	mut properties := map[string]SchemaRef{}
	for field in struct_.fields {
		mut property_schema := SchemaRef(Schema{})
		if field.typ.symbol.starts_with('_VAnonStruct') {
			property_schema = struct_to_schema(field.anon_struct)
		} else {
			property_schema = typesymbol_to_schema(field.typ.symbol)
		}
		if mut property_schema is Schema {
			properties[field.name] = SchemaRef(
				Schema {
					typ: property_schema.typ
					title: property_schema.title
					description: field.description
				}
			)
		} else {
			properties[field.name] = property_schema
		}
	}

	title := if struct_.name.starts_with('_VAnonStruct') {
		''} else {
			struct_.name
		}
	
	return SchemaRef(Schema{
		title: title
		description: struct_.description
		properties: properties
	})
}

// typesymbol_to_schema receives a typesymbol, if the typesymbol belongs to a user defined struct
// it returns a reference to the schema, else it returns a schema for the typesymbol
pub fn typesymbol_to_schema(symbol_ string) SchemaRef {
	mut symbol := symbol_.trim_string_left('!').trim_string_left('?')
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
	} else if symbol.starts_with('_VAnonStruct') {
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
		if symbol == 'byte' {
			return SchemaRef(Schema{typ: 'string'})
		}
		return SchemaRef(Schema{typ: symbol})
	}
}