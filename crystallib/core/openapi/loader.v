module openapi

import os
import x.json2
import json


pub fn load(path string) !OpenAPI{
	spec_json := os.read_file(path)!
	spec := json2.raw_decode(spec_json)!
	
	return parse_openapi(spec)!
}

fn parse_openapi(p json2.Any) !OpenAPI{
	mp := p.as_map()
	info := mp['info'] or { return error('info is required')}
	openapi_version := mp['openapi'] or {return error('openapi version is required')}

	mut ret := OpenAPI{
		openapi: openapi_version.str()
		info: parse_info(info)!
	}
	
	if json_schema_dialect := mp['json_schema_dialect']{
		ret.json_schema_dialect = json_schema_dialect.str()
	}
	
	if servers := mp['servers']{
		ret.servers = parse_servers(servers)!
	}

	if paths := mp['paths']{
		ret.paths = parse_paths(paths)!
	}

	if webhooks := mp['webhooks']{
		ret.webhooks = parse_webhooks(webhooks)!
	}

	if components := mp['components']{
		ret.components = parse_components(components)!
	}

	if security := mp['security']{
		ret.security = parse_security(security)!
	}

	if tags := mp['tags']{
		ret.tags = parse_tags(tags)!
	}

	if external_docs := mp['externalDocs']{
		ret.external_docs = parse_external_docs(external_docs)!
	}

	return ret
}

fn parse_info(p json2.Any) !Info{
	str := p.json_str()
	return json.decode(Info, str)!
}

fn parse_webhooks(p json2.Any) !map[string]PathRef{
	return map[string]PathRef{}
}

fn parse_components(p json2.Any) !Components{
	mp := p.as_map()
	
	mut schemas := map[string]Schema{}
	if schemas_ := mp['schemas']{
		schemas = json.decode(map[string]Schema, schemas_.json_str())!
	}

	mut responses := map[string]ResponseRef{}
	if responses_ := mp['responses']{
		responses = parse_responses(responses_)!
	}

	mut parameters := map[string]ParameterRef{}
	if parameters_ := mp['parameters']{
		parameters = parse_component_parameters(parameters_)!
	}

	mut examples := map[string]ExampleRef{}
	if examples_ := mp['examples']{
		examples = parse_examples(examples_)!
	}

	mut request_bodies := map[string]RequestRef{}
	if request_bodies_ := mp['request_bodies']{
		request_bodies = parse_request_bodies(request_bodies_)!
	}

	mut headers := map[string]HeaderRef{}
	if headers_ := mp['headers']{
		headers = parse_headers(headers_)!
	}

	mut security_schemes := map[string]SecuritySchemeRef{}
	if security_schemes_ := mp['securitySchemes']{
		security_schemes = parse_security_schemes(security_schemes_)!
	}

	mut links := map[string]LinkRef{}
	if links_ := mp['links']{
		links = parse_links(links_)!
	}

	mut callbacks :=  map[string]CallbackRef{}
	if callbacks_ := mp['callbacks']{
		callbacks = parse_callbacks(callbacks_)!
	}

	mut path_items := map[string]PathItemRef{}
	if path_items_ := mp['path_items']{
		path_items = parse_path_items(path_items_)!
	}

	return Components{
		schemas: schemas
		responses: responses
		parameters: parameters
		examples: examples
		request_bodies: request_bodies
		headers: headers
		security_schemes: security_schemes
		links: links
		callbacks: callbacks
		path_items: path_items
	}
}

fn parse_path_items(p json2.Any) !map[string]PathItemRef{
	mut ret := map[string]PathItemRef{}
	for k, v in p.as_map(){
		ret[k] = parse_path_item_ref(v)!
	}

	return ret
}

fn parse_path_item_ref(p json2.Any) !PathItemRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return parse_path_item(p)!
}

fn parse_security_schemes(p json2.Any) !map[string]SecuritySchemeRef{
	mut ret := map[string]SecuritySchemeRef{}
	for k, v in p.as_map(){
		ret[k] = parse_security_scheme(v)!
	}

	return ret
}

fn parse_security_scheme(p json2.Any) !SecuritySchemeRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return json.decode(SecurityScheme, p.json_str())!
}

fn parse_request_bodies(p json2.Any) !map[string]RequestRef{
	mut ret := map[string]RequestRef{}
	for k, v in p.as_map(){
		ret[k] = parse_request_body(v)!
	}

	return ret
}

fn parse_component_parameters(p json2.Any) !map[string]ParameterRef{
	mut ret := map[string]ParameterRef{}
	for k, v in p.as_map(){
		ret[k] = parse_parameter_ref(v)!
	}

	return ret
}

fn parse_parameter_ref(p json2.Any) !ParameterRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return parse_parameter(p)!
}

fn parse_tags(p json2.Any) ![]Tag{
	mut ret := []Tag{}
	for t in p.arr(){
		ret << json.decode(Tag, t.json_str())!
	}
	return []Tag{}
}

fn parse_str_arr(array json2.Any) []string {
	mut result := []string{}
	for element in array.arr() {
		result << element.str()
	}
	return result
}

fn parse_external_docs(p json2.Any) !ExternalDocumentation{
	return json.decode(ExternalDocumentation, p.json_str())!
}

fn parse_parameters(p json2.Any) ![]Parameter{
	mut ret := []Parameter{}
	for parameter in p.arr(){
		ret << parse_parameter(parameter)!
	}

	return ret
}

fn parse_parameter(p json2.Any) !Parameter{
	mp := p.as_map()

	name := mp['name'] or { return error('parameter name is required') }
	in_ := mp['in'] or { return error('parameter location is required') }
	required := mp['required'] or {return error('parameter required field is required')}
	mut ret := Parameter{
		name: name.str()
		in_: in_.str()
		required: required.bool()
	}

	if description := mp['description']{
		ret.description = description.str()
	}

	if deprecated := mp['deprecated']{
		ret.deprecated = deprecated.bool()
	}

	if allow_empty_value := mp['allowEmptyValue']{
		ret.allow_empty_value = allow_empty_value.bool()
	}

	if schema := mp['schema']{
		ret.schema = parse_schema(schema)!
	}

	return ret
}

fn parse_schema(p json2.Any) !Schema{
	return json.decode(Schema, p.json_str())!
}

fn parse_request_body(p json2.Any) !RequestRef{
	mp := p.as_map()
	if _ := mp['\$ref'] {
		return json.decode(Reference, p.json_str())!
	}

	return parse_request(p)!
}

fn parse_request(p json2.Any) !RequestBody{
	mp := p.as_map()
	description := mp['description'] or { '' }
	content_ := mp['content'] or {return error('request content is required')}
	content := parse_response_content(content_)!

	return RequestBody{
		description: description.str()
		content: content
	}
}

fn parse_responses(r json2.Any) !map[string]ResponseRef{
	mut ret := map[string]ResponseRef{}
	for k, v in r.as_map(){
		ret[k] = parse_response_ref(v)!
	}

	return ret
}

fn parse_response_ref(p json2.Any) !ResponseRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return parse_response(p)!
}

fn parse_response(p json2.Any) !Response{
	mp := p.as_map()
	description := mp['description'] or { return error('response desciption is required') }
	mut ret := Response{
		description: description.str()
	}

	if headers := mp['headers']{
		ret.headers = parse_headers(headers)!
	}

	if content := mp['content']{
		ret.content = parse_response_content(content)!
	}

	if links := mp['links']{
		ret.links = parse_links(links)!
	}

	return ret
}

fn parse_links(p json2.Any) !map[string]LinkRef{
	mut ret := map[string]LinkRef{}
	for k, v in p.as_map(){
		ret[k] = parse_link_ref(v)!
	}

	return ret
}

fn parse_link_ref(p json2.Any) !LinkRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return json.decode(Link, p.json_str())!
}

fn parse_response_content(p json2.Any) !map[string]MediaType{
	mut ret := map[string]MediaType{}
	for k, v in p.as_map(){
		ret[k] = parse_media_type(v)!
	}

	return ret
}

fn parse_media_type(p json2.Any) !MediaType{
	mp := p.as_map()
	mut ret := MediaType{}
	if schema := mp['schema']{
		ret.schema = json.decode(Schema, schema.json_str())!
	}

	if example := mp['example']{
		ret.example = example.str()
	}

	if examples := mp['examples']{
		ret.examples = parse_examples(examples)!
	}

	if encodings := mp['encoding']{
		ret.encoding = parse_encodings(encodings)!
	}

	return ret
}

fn parse_encodings(p json2.Any) !map[string]Encoding{
	mut ret := map[string]Encoding{}
	for k, v in p.as_map(){
		ret[k] = parse_encoding(v)!
	}

	return ret
}

fn parse_encoding(p json2.Any) !Encoding{
	mp := p.as_map()
	content_type := mp['contentType'] or { '' }
	style := mp['style'] or {''}
	explode := mp['explode'] or {false}
	allow_reserved := mp['allow_reserved'] or {false}
	mut headers_map := map[string]HeaderRef{}
	if headers := mp['headers']{
		for k, v in headers.as_map(){
			headers_map[k] = parse_header_ref(v)!
		}
	}

	return Encoding{
		content_type: content_type.str()
		style: style.str()
		explode: explode.bool()
		allow_reserved: allow_reserved.bool()
		headers: headers_map
	}
}

fn parse_example(p json2.Any) !ExampleRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return json.decode(Example, p.json_str())!
}

fn parse_examples(p json2.Any) !map[string]ExampleRef{
	mut ret := map[string]ExampleRef{}
	for k, v in p.as_map(){
		ret[k] = parse_example(v)!
	}

	return ret
}

fn parse_headers(p json2.Any) !map[string]HeaderRef{
	mut ret := map[string]HeaderRef{}
	for k, v in p.as_map(){
		ret[k] = parse_header_ref(v)!
	}

	return ret
}

fn parse_header_ref(p json2.Any) !HeaderRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return json.decode(Header, p.json_str())!
}

fn parse_callbacks(p json2.Any) !map[string]CallbackRef{
	mut ret := map[string]CallbackRef{}
	for k, v in p.as_map(){
		ret[k] = parse_callback_ref(v)!
	}

	return ret
}

fn parse_callback_ref(p json2.Any) !CallbackRef{
	mp := p.as_map()
	if _ := mp['\$ref']{
		return json.decode(Reference, p.json_str())!
	}

	return json.decode(Callback, p.json_str())!
}

fn parse_security(p json2.Any) ![]SecurityRequirement{
	mut ret := []SecurityRequirement{}
	for requirement in p.arr(){
		ret << json.decode(SecurityRequirement, requirement.json_str())!
	}

	return ret
}

fn parse_servers(p json2.Any) ![]Server{
	mut ret := []Server{}
	for server in p.arr(){
		ret << json.decode(Server, server.json_str())!
	}

	return ret
}

fn parse_paths(p json2.Any) !map[string]PathItem{
	paths := p.as_map()
	mut path_items := map[string]PathItem{}
	for path, item in paths {
		path_items[path] = parse_path_item(item)!
	}

	return path_items
}

fn parse_path_item(p json2.Any) !PathItem{
	mut ret := PathItem{}
	path_item := p.as_map()

	if ref := path_item['ref']{
		ret.ref = ref.str()
	}

	if summary := path_item['summary']{
		ret.summary = summary.str()
	}

	if description := path_item['description']{
		ret.description = description.str()
	}

	if get := path_item['get']{
		ret.get = parse_operation(get)!
	}

	if put := path_item['put']{
		ret.put = parse_operation(put)!
	}

	if post := path_item['post']{
		ret.post = parse_operation(post)!
	}

	if del := path_item['delete']{
		ret.delete = parse_operation(del)!
	}

	if options := path_item['options']{
		ret.options = parse_operation(options)!
	}

	if head := path_item['head']{
		ret.head = parse_operation(head)!
	}

	if patch := path_item['patch']{
		ret.patch = parse_operation(patch)!
	}

	if trace := path_item['trace']{
		ret.trace = parse_operation(trace)!
	}

	if servers := path_item['servers']{
		ret.servers = parse_servers(servers)!
	}

	if parameters := path_item['paramters']{
		ret.parameters = parse_parameters(parameters)!
	}

	return ret
}

pub fn parse_operation(p json2.Any) !Operation{
	props := p.as_map()
	mut operation := Operation{}
	if tags := props['tags'] {
		operation.tags = parse_str_arr(tags)
	}

	if summary := props['summary']{
		operation.summary = summary.str()
	}

	if description := props['description']{
		operation.description = description.str()
	}

	if external_docs := props['externalDocs']{
		operation.external_docs = parse_external_docs(external_docs)!
	}

	if operation_id := props['operationId']{
		operation.operation_id = operation_id.str()
	}

	if parameters := props['parameters']{
		operation.parameters = parse_parameters(parameters)!
	}

	if request_body := props['requestBody']{
		operation.request_body = parse_request_body(request_body)!
	}

	if responses := props['responses']{
		operation.responses = parse_responses(responses)!
	}

	if callbacks := props['callbacks']{
		operation.callbacks = parse_callbacks(callbacks)!
	}

	if deprecated := props['deprecated']{
		operation.deprecated = deprecated.bool()
	}

	if security := props['security']{
		operation.security = parse_security(security)!
	}

	if servers := props['servers']{
		operation.servers = parse_servers(servers)!
	}

	return operation
}