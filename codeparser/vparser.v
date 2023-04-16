module codeparser

import v.ast
import v.parser
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.codemodel {CodeItem, Function, Struct, StructField, Param, Type, Result}
import v.pref

const (
	fpref = &pref.Preferences{
		is_fmt: true
	}
)

// VParser holds configuration of parsing
// has methods that parse subparts of the code
[params]
pub struct VParser {
	exclude_dirs []string // directories to be excluded from parsing
	exclude_files []string // files to be excluded from parsing
	only_pub bool // whether to only parse public functions and structs
	recursive bool // whether subdirs should be parsed as well
}

// parse_v
pub fn parse_v(path_ string, vparser VParser) ![]CodeItem {
	mut path := pathlib.get(path_)
	if !path.exists() {
		return error('Path `$path.path` doesn\'t exist.')
	}

	path.check()
	return vparser.parse_vpath(path)!
}

// parse_vpath parses the v code files in a given path
// can be recursive or not based on the parsers configuration
// returns codeitems from the entire path
fn (vparser VParser) parse_vpath(path pathlib.Path) ![]CodeItem {
	$if debug {
		println('Parsing path `$path.path`')
	}

	mut code := []CodeItem{}
	if path.is_dir() {
		dir_is_excluded := vparser.exclude_dirs.any(path.path.ends_with(it))
		if dir_is_excluded {
			return code
		}

		if vparser.recursive {
			// parse subdirs if configured recursive
			subdirs := path.dir_list()!
			for subdir in subdirs {
				code << vparser.parse_vpath(subdir)!
			}
		}

		files := path.file_list()!
		for file in files {
			code << vparser.parse_vpath(file)!
		}
	} else if path.is_file() {
		file_is_excluded := vparser.exclude_files.any(path.path.ends_with(it))
		if file_is_excluded {
			return code
		}
		code << vparser.parse_vfile(path.path)
	} else {
		return error('Path being parsed must either be a directory or a file.')
	}

	return code
}

// parse_vfile parses a v code file 
// returns the code items that are in the file
fn (vparser VParser) parse_vfile(path string) []CodeItem {
	mut code := []CodeItem{}

	table := ast.new_table()
	file_ast := parser.parse_file(path, table, .parse_comments, fpref)
	mut preceeding_comments := []ast.Comment

	for stmt in file_ast.stmts {
		// code block from vlib/v/doc/doc.v
		if stmt is ast.ExprStmt {
			// Collect comments
			if stmt.expr is ast.Comment {
				preceeding_comments << stmt.expr as ast.Comment
				continue
			}
		}
		if stmt is ast.FnDecl {
			fn_decl := stmt as ast.FnDecl 
			if fn_decl.is_pub || !vparser.only_pub {
				code << CodeItem(vparser.parse_vfunc(
					fn_decl: fn_decl
					table: table
					comments: preceeding_comments
				))
			}
		} else if stmt is ast.StructDecl {
			struct_decl := stmt as ast.StructDecl
			if struct_decl.is_pub || !vparser.only_pub {
				code << CodeItem(vparser.parse_vstruct(
					struct_decl: struct_decl
					table: table
					comments: preceeding_comments
				))
			}
		}
	}
	return code
}

[params]
struct VFuncArgs {
	comments []ast.Comment // v comments that belong to the function
	fn_decl ast.FnDecl // v.ast parsed function declaration
	table ast.Table // ast table used for getting typesymbols from
}

// parse_vfunc parses function args into function struct
pub fn (vparser VParser) parse_vfunc(args VFuncArgs) Function {
	$if debug {
		println('Parsing function: $args.fn_decl.short_name')
	}

	result := vparser.parse_result(
		comments: args.comments
		return_type: args.fn_decl.return_type
		table: args.table
	)

	return Function{
		name: args.fn_decl.short_name
		params: vparser.parse_params(
			params: args.fn_decl.params
			table: args.table
		)
		result: result
	}
}

[params]
struct ParamsArgs {
	comments []ast.Comment // comments of the function
	params []ast.Param // ast type of what function returns
	table ast.Table // ast table for getting type names 
}

// parse_params parses ast function parameters into function parameters
fn (vparser VParser)parse_params(args ParamsArgs) []Param {
	$if debug {
		println('Parsing params: ${args.params.map(it.name)}')
	}
	
	return args.params.map(
		Param{
			name: it.name
			typ: Type{
				symbol: args.table.type_to_str(it.typ).all_after_last('.')
			}
		}
	)
}

struct ReturnArgs {
	comments []ast.Comment // comments of the function
	return_type ast.Type // v.ast type of what function returns
	table ast.Table // v.ast table for getting type names 
}

fn (vparser VParser)parse_result(args ReturnArgs) Result {
	comment_str := args.comments.map(it.text).join('')

	mut name := ''
	mut description := ''
	if start := comment_str.index('returns') {
		end := comment_str[start..].index('.') or {comment_str.len - 1}
		return_str := comment_str[start..end].trim_string_left('returns ')

		split := return_str.split(', ')
		name = split[0]
		if split.len > 1 {
			description = split[1..].join(', ')
		}
	}

	return_symbol := args.table.type_to_str(args.return_type).all_after_last('.')
	
	return Result {
		name: name
		description: description
		typ: Type {
			symbol: return_symbol
		}
	}
}

// parse_params parses ast function parameters into function parameters
fn (vparser VParser)parse_type(typ ast.Type, table ast.Table) Type {
	$if debug {
		println('Parsing type: $typ')
	}

	type_str := table.type_to_str(typ).all_after_last('.')
	return Type {
		symbol: type_str
	}
}

struct VStructArgs {
	comments []ast.Comment // comments that belong to the struct declaration
	struct_decl ast.StructDecl // v.ast Struct declaration for struct being parsed
	table ast.Table // v.ast table for getting type names 
}

// parse_params parses struct args into struct
fn (vparser VParser) parse_vstruct(args VStructArgs) Struct {
	$if debug {
		println('Parsing struct: $args.struct_decl.name')
	}
	return Struct{
		name: args.struct_decl.name.all_after_last('.')
		fields: vparser.parse_fields(args.struct_decl.fields, args.table)
	}
}

// parse_fields parses ast struct fields into struct fields
fn (vparser VParser)parse_fields(fields []ast.StructField, table ast.Table) []StructField {
	$if debug {
		println('Parsing fields: ${fields.map(it.name)}')
	}
	return fields.map(
		StructField{
			name: it.name
			typ: Type{
				symbol: table.type_to_str(it.typ).all_after_last('.')
			}
		}
	)
}
