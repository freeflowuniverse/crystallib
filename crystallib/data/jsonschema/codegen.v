module jsonschema

const vtypes = {
	'integer': 'int'
	'string':  'string'
}

pub fn (schema Schema) v_encode() !string {
	module_name := 'schema.title.'
	structs := schema.vstructs_encode()!
	// todo: report bug: return $tmpl(...)
	encoded := $tmpl('templates/schema.vtemplate')
	return encoded
}

// vstructs_encode encodes a schema into V structs.
// if a schema has nested object type schemas or defines object type schemas,
// recrusively encodes object type schemas and pushes to the array of structs.
// returns an array of schemas that have been encoded into V structs.
pub fn (schema Schema) vstructs_encode() ![]string {
	mut schemas := []string{}
	mut properties := ''

	// loop over properties
	for name, property_ in schema.properties {
		mut property := Schema{}
		mut typesymbol := ''

		if property_ is Reference {
			// if reference, set typesymbol as reference name
			ref := property_ as Reference
			typesymbol = ref.ref.all_after_last('/')
		} else {
			property = property_ as Schema
			typesymbol = property.vtype_encode()!
			// recursively encode property if object
			// todo: handle duplicates
			if property.typ == 'object' {
				structs := property.vstructs_encode()!
				schemas << structs
			}
		}

		properties += '\n\t${name} ${typesymbol}'
		if name in schema.required {
			properties += ' [required]'
		}
	}
	schemas << $tmpl('templates/struct.vtemplate')
	return schemas
}

// code_type generates a typesymbol for the schema
pub fn (schema Schema) vtype_encode() !string {
	mut property_str := ''
	if schema.typ == 'object' {
		if schema.title == '' {
			return error('Object schemas must define a title.')
		}
		// todo: enfore uppercase
		property_str = schema.title
	} else if schema.typ == 'array' {
		// todo: handle multiple item schemas
		if schema.items is SchemaRef {
			// items := schema.items as SchemaRef
			if schema.items is Schema {
				items_schema := schema.items as Schema
				property_str = '[]${items_schema.typ}'
			}
		}
	} else if schema.typ in jsonschema.vtypes.keys() {
		property_str = jsonschema.vtypes[schema.typ]
	} else {
		return error('unknown type `${schema.typ}` ')
	}
	return property_str
}
