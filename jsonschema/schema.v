module jsonschema

type Items = SchemaRef | []SchemaRef

pub type SchemaRef = Reference | Schema

pub struct Reference {
pub:
	ref string [json: '\$ref'; required]
}

type Number = int

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
	one_of                ?[]SchemaRef         [json: 'oneOf']

	// todo: make fields optional upon the fixing of https://github.com/vlang/v/issues/18775
	// from https://git.sr.ht/~emersion/go-jsonschema/tree/master/item/schema.go
	// Validation for numbers
	multiple_of       Number [json: 'multipleOf'; omitempty]
	maximum           Number [omitempty]
	exclusive_maximum Number [json: 'exclusiveMaximum'; omitempty]
	minimum           Number [omitempty]
	exclusive_minimum Number [json: 'exclusiveMinimum'; omitempty]
}
