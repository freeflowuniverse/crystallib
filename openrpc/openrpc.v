module openrpc

import freeflowuniverse.crystallib.jsonschema {SchemaRef, Reference}
import time

pub struct OpenRPC {
	pub mut:
	openrpc string [required] = '1.0.0'
	info Info [required]
	servers []Server
	methods []Method [required]
	components Components
	external_docs []ExternalDocs [json: externalDocs]
}

pub struct Info{
	title string [required]
	description string
	terms_of_service string [json: termsOfService]
	contact Contact
	license License
	version string [required]
}

pub struct Contact {
	name string
	email string
	url string
}

pub struct License {
	name string [required] = ''
	url string
}

pub struct Server{
	name string
	url string // todo: runtime expression
	summary string
	description string
	variables map[string]ServerVariable
}

pub struct ServerVariable {
	enum_ []string [json: 'enum']
	default_ string [json: 'default']
	description string
}

// https://spec.open-rpc.org/#method-object
pub struct Method {
	pub:
	name string [required]
	tags []TagRef
	summary string
	description string
	external_docs ExternalDocs [json: externalDocs]
	params []ContentDescriptorRef [required]
	result ContentDescriptorRef
	deprecated bool
	servers []Server
	errors []ErrorRef
	links []LinkRef
	param_structure string [json: paramStructure] = 'either' // todo, make paramformat enum
	examples []ExamplePairing
}

pub type ContentDescriptorRef = ContentDescriptor | jsonschema.Reference

pub struct ContentDescriptor {
	pub:
	name string [required] = ''
	summary string
	description string
	required bool
	schema SchemaRef //required
	deprecated bool
}

pub struct ExamplePairing {
	name string
	description  string
	summary string
	params []ExampleRef
	result ExampleRef
}

type ExampleRef = Example | Reference

pub struct Example{
	name string
	summary string
	description string
	value string // Question: how to handle any?
	external_value string [json: externalValue]
}

type LinkRef = Link | Reference

pub struct Link {
	name string
	description string
	summary string
	method string
	params map[string]string // todo runtime expression
	server Server
}

type ErrorRef = Error | Reference

pub struct Error {
	code int [required]
	message string [required]
	data string
}

pub struct Components {
	content_descriptors map[string]ContentDescriptor [json: contentDescriptors]
	schemas map[string]jsonschema.SchemaRef
	examples map[string]Example
	links map[string]Link
	error map[string]Error
	example_pairing_objects map[string]ExamplePairing [json: examplePairingObjects]
	tags map[string]Tag
}

type TagRef = Tag | Reference

pub struct Tag {
	name string [required]
	summary string
	description string
	external_docs ExternalDocs [json: externalDocs]
}

pub struct ExternalDocs {
	description string
	url string //[required]
}

// todo: implement specification extensions

pub struct Property {
	description string
	typ string [json: 'type']
	exclusive_minimum int [json: exclusiveMinimum]
	min_items int [json: minItems]
	unique_items bool [json: uniqueItems]
}

pub struct Value {
	versions []Version
}

pub struct Version {
	status string
	updated time.Time
	id string
	urls []URL
}

pub struct URL {
	href string
	rel string
}
