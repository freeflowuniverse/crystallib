module docgen

import v.ast
import v.doc
import os
import v.pref
import v.parser as vparser
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.jsonschema { Reference, Schema, SchemaRef }
import freeflowuniverse.crystallib.openrpc { ContentDescriptor, ContentDescriptorRef }

const (
	fpref = &pref.Preferences{
		is_fmt: true
	}
)

[noinit]
struct Parser {
mut:
	table    ast.Table
	file_ast ast.File
	methods  []openrpc.Method
	schemas  map[string]SchemaRef
	examples map[string]openrpc.Example
	vdocs    []doc.Doc
}

pub fn new() Parser {
	return Parser{
		table: ast.new_table()
	}
}

// parse parses RPC methods in a given path to an OpenRPC specification structure
// returns filled in OpenRPC specification struct
pub fn (mut parser Parser) parse(path_ string) ! {
	$if debug {
		eprintln('Parsing path: ${path_}')
	}

	mut path := pathlib.get(path_)
	path.check()
	if !path.is_file() && !path.is_dir() {
		return error('Path must be either a file or a directory.')
	}

	mut dcs := doc.new(path.path)
	dcs.pub_only = true
	dcs.with_comments = true
	dcs.prefs.os = pref.get_host_os()
	dcs.generate()!
	println('DOC:${dcs}')

	for key, content in dcs.contents {
		parser.parse_recursive(content)!
	}
}

pub fn (mut parser Parser) parse_recursive(node doc.DocNode) ! {
	for child in node.children {
		parser.parse_recursive(child)!
	}

	if node.kind.str() == 'fn' {
		mut params := []Param{}

		split_content := node.content.split(node.name)
		mut params_str := ''
		if split_content.len > 1 {
			if !split_content[1].starts_with('()') {
				fn_params := split_content[1]
				params_str = fn_params[1..].split(')')[0]
				split := params_str.split(',')
				params = split.map(Param{
					name: it.split(' ')[0]
					typ: it.split(' ')[1]
				})
			}
		} else {
			return error('Expected to find ${node.name} in ${node.content}')
		}

		if node.is_pub {
			parser.parse_method(
				name: node.name
				params: params
				return_type: node.return_type
			)!
		}
	} else if node.kind.str() == 'struct' {
		parser.parse_schema(node)!
	}
}

struct Param {
	name string
	typ  string
}

struct MethodArgs1 {
	name        string
	params      []Param
	return_type string
}

// parse_method parses a V function declaration into an OpenRPC Method Structure
// returns parsed method structure
pub fn (mut parser Parser) parse_method(args MethodArgs1) ! {
	$if debug {
		eprintln('Parse method: ${args.name}')
	}

	params := get_param_descriptors(args.params)
	result := get_result_descriptor(args.return_type)!

	parser.methods << openrpc.Method{
		name: args.name
		params: params
		result: result
	}
}

// get_param_descriptors takes in a list of params
// returns content descriptors for the params
fn get_param_descriptors(params []Param) []ContentDescriptorRef {
	mut descriptors := []ContentDescriptorRef{}

	for param in params {
		schemaref := get_schema_from_typesymbol(param.typ)
		descriptors << ContentDescriptorRef(ContentDescriptor{
			name: param.name
			schema: schemaref
		})
	}

	return descriptors
}

// get_result_descriptor takes a V function's DocNode
// parses it's return type and description of what the function returns from the comments
// returns result descriptor: Content Descriptor that describes what a function returns
fn get_result_descriptor(return_type string) !ContentDescriptorRef {
	schemaref := get_schema_from_typesymbol(return_type)

	return ContentDescriptor{
		name: return_type
		schema: schemaref
	}
}

// get schema_from_typesymbol receives a typesymbol, if the typesymbol belongs to a user defined struct
// it returns a reference to the schema, else it returns a schema for the typesymbol
fn get_schema_from_typesymbol(symbol string) SchemaRef {
	if symbol.contains('[]') {
		mut array_type := symbol.trim_string_left('[]')
		return SchemaRef(Schema{
			typ: 'array'
			items: get_schema_from_typesymbol(array_type)
		})
	} else if symbol[0].is_capital() {
		return SchemaRef(Reference{
			ref: '#/components/schemas/${symbol}'
		})
	} else {
		if symbol == 'void' {
			return SchemaRef(Schema{
				typ: 'null'
			})
		}
		return SchemaRef(Schema{
			typ: symbol
		})
	}
}

// parse_method parses a V function declaration into an OpenRPC Method Structure
// returns parsed method structure
pub fn (mut parser Parser) parse_schema(node doc.DocNode) ! {
	$if debug {
		eprintln('Parse schema: ${node}')
		// eprintln(statement)
	}

	lines := node.content.split('\n')
	mut field_lines := []string{}
	mut in_field := false
	for line in lines {
		if line.trim_space().ends_with('}') {
			in_field = false
		}

		if in_field {
			field_lines << line
		}
		if line.trim_space().ends_with('{') {
			in_field = true
		}
	}

	mut properties := map[string]SchemaRef{}
	for line_ in field_lines {
		line := line_.trim_space()
		split := line.split(' ')
		name := split[0].trim_space()
		symbol := split[1..].join('').trim_space()
		properties[name] = get_schema_from_typesymbol(symbol)
	}

	parser.schemas[node.name] = SchemaRef(Schema{
		title: node.name
		properties: properties
	})
}
