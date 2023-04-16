module docgen

import v.ast
import os
import v.parser as vparser
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.openrpc { ContentDescriptor }

const testpath = os.dir(@FILE) + '/testdata'

// test parser factory
pub fn test_new() {
	parser := new()
	assert true
}

// test parsing a file
fn test_parse_method_plain() ! {
	table := ast.new_table()
	file_ast := vparser.parse_file('${docgen.testpath}/method_plain.v', table, .parse_comments,
		fpref)
	fn_stmt := file_ast.stmts[1] as ast.FnDecl

	method := parse_method(
		statement: fn_stmt
	)
	assert method.name == 'method_plain'
	assert method.summary == ''
	assert method.params.len == 0
	assert method.result is ContentDescriptor
	result_descriptor := method.result as ContentDescriptor
	assert result_descriptor.name == ''
}

// test parsing a file
fn test_parse_method_with_description() ! {
	mut parser := new()
	path := pathlib.get('${docgen.testpath}/method_with_description.v')
	parser.parse_file(path) or { panic('Failed to parse file `${path}`\n${err}') }
	// method := parser.specs.methods[0]
	// assert method.name == 'method_with_description'
	// assert method.description == "shows that the parser can parse a method's description from its comments, even if the comments are multiline."
	// assert method.summary == ''
	// assert method.params.len == 0
	// assert method.result is ContentDescriptor
	// result_descriptor := method.result as ContentDescriptor
	// assert result_descriptor.name == ''
}

// test parsing a file
pub fn test_parse_file() ! {
	mut parser := new()
	path := pathlib.get('${docgen.testpath}/methods.v')
	parser.parse_file(path) or { panic('Failed to parse file `${path}`\n${err}') }
	assert parser.specs.methods.len == 6
	assert parser.specs.methods[0].name == 'plain_method'
	assert parser.specs.methods[5].name == 'method_with_params'
}

// test parsing a directory
pub fn test_parse_dir() {
	mut parser := new()
	path := pathlib.get(docgen.testpath)
	parser.parse_dir(path) or { panic('Failed to parse `${path}`\n${err}') }
	// assert parser.specs.methods.len == 7
	// assert parser.specs.methods[1].name == 'plain_method'
	// assert parser.specs.methods[6].name == 'method_with_params'
}

// test parsing a directory
pub fn test_parse() {
	mut parser := new()
	specs := parser.parse(docgen.testpath) or {
		panic('Failed to parse `${docgen.testpath}`\n${err}')
	}
	// assert specs.methods.len == 7
	// assert specs.methods.map(it.name) == ['method_plain', 'plain_method', 'method_with_body', 'method_with_comment', 'method_with_param', 'method_with_return', 'method_with_params']
}
