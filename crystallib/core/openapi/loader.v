module openapi

import os
import x.json2 as json


fn load(path string) !OpenAPI{
	spec_json := os.read_file(path)!
	spec := json.raw_decode(spec_json)!

	return parse_openapi(spec)!
}

fn parse_openapi(p json.Any) !OpenAPI{
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

fn parse_info(p json.Any) !Info{
	mp := p.as_map()
	title := mp['title'] or { return error('info title is required') }
	version := mp['version'] or {return error('info version is required')}
	mut ret := Info{
		title: title.str()
		version: version.str()
	}

	if summary := mp['summary']{
		ret.summary = summary.str()
	}

	if description := mp['description']{
		ret.description = description.str()
	}

	if terms_of_service := mp['terms_of_service']{
		ret.terms_of_service = terms_of_service.str()
	}

	if contact := mp['contact']{
		ret.contact = parse_contact(contact)!
	}

	if license := mp['license']{
		ret.license = parse_license(license)!
	}

	return ret
}

fn parse_contact(p json.Any) !Contact{
	return Contact{}
}

fn parse_license(p json.Any) !License{
	mp := p.as_map()
	name := mp['name'] or { return error('license name is required') }
	mut ret := License{
		name: name.str()
	}

	if identifier := mp['identifier']{
		ret.identifier = identifier.str()
	}

	if url := mp['url']{
		ret.url = url.str()
	}

	return ret
}

fn parse_webhooks(p json.Any) !map[string]PathRef{
	return map[string]PathRef{}
}

fn parse_components(p json.Any) !Components{
	return Components{}
}

fn parse_tags(p json.Any) ![]Tag{
	return []Tag{}
}

fn parse_str_arr(array json.Any) []string {
	mut result := []string{}
	for element in array.arr() {
		result << element.str()
	}
	return result
}

fn parse_external_docs(ext json.Any) !ExternalDocumentation{
	mp := ext.as_map()
	url := mp['url'] or { return error('external documentation url is required') }

	mut ret := ExternalDocumentation{
		url: url.str()
	}

	if description := mp['description']{
		ret.description = description.str()
	}

	return ret
}

fn parse_parameters(p json.Any) ![]Parameter{
	mut ret := []Parameter{}
	for parameter in p.arr(){
		ret << parse_parameter(parameter)!
	}

	return ret
}

fn parse_parameter(p json.Any) !Parameter{
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

fn parse_schema(p json.Any) !Schema{
	return Schema{}
}

fn parse_request_body(p json.Any) !RequestRef{
	return RequestRef{}
}

fn parse_responses(r json.Any) !map[string]ResponseRef{
	return map[string]ResponseRef{}
}

fn parse_callbacks(c json.Any) !map[string]CallbackRef{
	return map[string]CallbackRef{}
}

fn parse_security(s json.Any) ![]SecurityRequirement{
	return []SecurityRequirement{}
}

fn parse_servers(s json.Any) ![]Server{
	return []Server{}
}

fn parse_paths(p json.Any) !map[string]PathItem{
	paths := p.as_map()
	mut path_items := map[string]PathItem{}
	for path, item in paths {
		path_items[path] = parse_path_item(item)!
	}

	return path_items
}

fn parse_path_item(p json.Any) !PathItem{
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

	if delete := path_item['delete']{
		ret.delete = parse_operation(delete)!
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

pub fn parse_operation(p json.Any) !Operation{
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

	if operation_id := props['oprationId']{
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