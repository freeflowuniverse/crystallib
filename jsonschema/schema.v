module jsonschema

type Items = SchemaRef | []SchemaRef

pub type SchemaRef = Reference | Schema

pub struct Reference {
pub:
	ref string [json: '\$ref'; required]
}

// https://json-schema.org/draft-07/json-schema-release-notes.html
pub struct Schema {
pub mut:
	schema                string               [json: '\$schema']
	id                    string               [json: '\$id']
	title                 string
	description           string
	typ                   string               [json: 'type']
	properties            map[string]SchemaRef
	additional_properties SchemaRef            [json: 'additionalProperties']
	required              []string
	ref                   string
	items                 Items
	defs                  map[string]Schema
}
