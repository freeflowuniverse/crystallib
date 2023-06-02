module codeparser

import v.ast
import v.parser
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.codemodel { CodeItem, Function, Param, Result, Struct, StructField, Sumtype, Type }
import v.pref

// VParser holds configuration of parsing
// has methods that implement parsing
[params]
pub struct VParser {
	exclude_dirs  []string // directories to be excluded from parsing
	exclude_files []string // files to be excluded from parsing
	only_pub      bool     // whether to only parse public functions and structs
	recursive     bool     // whether subdirs should be parsed as well
}

// parse_v takes in a path to parse V code from and
// vparser configuration params, returns a list of parsed codeitems
pub fn parse_v(path_ string, vparser VParser) ![]CodeItem {
	mut path := pathlib.get(path_)

	$if debug {
		eprintln('Parsing path `${path.path}` with cofiguration:\n${vparser}\n')
	}

	if !path.exists() {
		return error('Path `${path.path}` doesn\'t exist.')
	}

	path.check()
	return vparser.parse_vpath(path)!
}

// parse_vpath parses the v code files and returns codeitems in a given path
// can be recursive or not based on the parsers configuration
fn (vparser VParser) parse_vpath(path pathlib.Path) ![]CodeItem {
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
		// todo: use pathlib list regex param to filter non-v files
		if file_is_excluded || !path.path.ends_with('.v') {
			return code
		}
		code << vparser.parse_vfile(path.path)
	} else {
		return error('Path being parsed must either be a directory or a file.')
	}
	return code
}

// parse_vfile parses and returns code items from a v code file
fn (vparser VParser) parse_vfile(path string) []CodeItem {
	$if debug {
		eprintln('Parsing file `${path}`')
	}
	mut code := []CodeItem{}

	table := ast.new_table()
	fpref := &pref.Preferences{ // preferences for parsing
		is_fmt: true
	}
	file_ast := parser.parse_file(path, table, .parse_comments, fpref)
	mut preceeding_comments := []ast.Comment{}

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
			if fn_decl.attrs.len > 0 {
				openrpc_attrs := fn_decl.attrs.filter(it.name == 'openrpc')
				{
					if openrpc_attrs.any(it.arg == 'exclude') {
						continue
					}
				}
			}
			if fn_decl.is_pub || !vparser.only_pub {
				code << CodeItem(vparser.parse_vfunc(
					fn_decl: fn_decl
					table: table
					comments: preceeding_comments
				))
			}
			preceeding_comments = []ast.Comment{}
		} else if stmt is ast.TypeDecl {
			if stmt is ast.SumTypeDecl {
				sumtype_decl := stmt as ast.SumTypeDecl
				if sumtype_decl.attrs.len > 0 {
					openrpc_attrs := sumtype_decl.attrs.filter(it.name == 'openrpc')
					{
						if openrpc_attrs.any(it.arg == 'exclude') {
							continue
						}
					}
				}
				if sumtype_decl.is_pub || !vparser.only_pub {
					code << CodeItem(vparser.parse_vsumtype(
						sumtype_decl: sumtype_decl
						table: table
						comments: preceeding_comments
					))
				}
				preceeding_comments = []ast.Comment{}
			}
		} else if stmt is ast.StructDecl {
			struct_decl := stmt as ast.StructDecl
			if struct_decl.attrs.len > 0 {
				openrpc_attrs := struct_decl.attrs.filter(it.name == 'openrpc')
				{
					if openrpc_attrs.any(it.arg == 'exclude') {
						continue
					}
				}
			}
			if struct_decl.is_pub || !vparser.only_pub {
				code << CodeItem(vparser.parse_vstruct(
					struct_decl: struct_decl
					table: table
					comments: preceeding_comments
				))
			}
			preceeding_comments = []ast.Comment{}
		}
	}
	return code
}

[params]
struct VFuncArgs {
	comments []ast.Comment // v comments that belong to the function
	fn_decl  ast.FnDecl    // v.ast parsed function declaration
	table    &ast.Table    // ast table used for getting typesymbols from
}

// parse_vfunc parses function args into function struct
pub fn (vparser VParser) parse_vfunc(args VFuncArgs) Function {
	$if debug {
		eprintln('Parsing function: ${args.fn_decl.short_name}')
	}

	// get function params excluding receiver
	receiver_name := args.fn_decl.receiver.name
	fn_params := args.fn_decl.params.filter(it.name != receiver_name)

	params := vparser.parse_params(
		comments: args.comments
		params: fn_params
		table: args.table
	)

	result := vparser.parse_result(
		comments: args.comments
		return_type: args.fn_decl.return_type
		table: args.table
	)

	mut fn_comments := []string{}
	for comment in args.comments.map(it.text.trim_string_left('\u0001').trim_space()) {
		if !comment.starts_with('-') && !comment.starts_with('returns') {
			fn_comments << comment.trim_string_left('${args.fn_decl.short_name} ')
		}
	}

	return Function{
		name: args.fn_decl.short_name
		description: fn_comments.join(' ')
		mod: args.fn_decl.mod
		params: params
		result: result
	}
}

[params]
struct ParamsArgs {
	comments []ast.Comment // comments of the function
	params   []ast.Param   // ast type of what function returns
	table    &ast.Table    // ast table for getting type names
}

// parse_params parses ast function parameters into function parameters
fn (vparser VParser) parse_params(args ParamsArgs) []Param {
	mut params := []Param{}
	for param in args.params {
		mut description := ''
		// parse comment line that describes param
		for comment in args.comments {
			if start := comment.text.index('- ${param.name}: ') {
				description = comment.text[start..].trim_string_left('- ${param.name}: ')
			}
		}

		params << Param{
			name: param.name
			description: description
			typ: Type{
				symbol: args.table.type_to_str(param.typ).all_after_last('.')
			}
		}
	}
	return params
}

struct ReturnArgs {
	comments    []ast.Comment // comments of the function
	return_type ast.Type      // v.ast type of what function returns
	table       &ast.Table    // v.ast table for getting type names
}

// parse_result parses a function's comments and return type
// returns a result struct that represents what the function's result is
fn (vparser VParser) parse_result(args ReturnArgs) Result {
	comment_str := args.comments.map(it.text).join('')

	// parse comments to get return name and description	
	mut name := ''
	mut description := ''
	if start := comment_str.index('returns') {
		mut end := comment_str.index_after('.', start)
		if end == -1 {
			end = comment_str.len
		}
		return_str := comment_str[start..end].trim_string_left('returns ')

		split := return_str.split(', ')
		name = split[0]
		if split.len > 1 {
			description = split[1..].join(', ')
		}
	}
	return_symbol := args.table.type_to_str(args.return_type).all_after_last('.')

	return Result{
		name: name
		description: description
		typ: Type{
			symbol: return_symbol
		}
	}
}

// parse_params parses ast function parameters into function parameters
fn (vparser VParser) parse_type(typ ast.Type, table &ast.Table) Type {
	type_str := table.type_to_str(typ).all_after_last('.')
	return Type{
		symbol: type_str
	}
}

struct VStructArgs {
	comments    []ast.Comment  // comments that belong to the struct declaration
	struct_decl ast.StructDecl // v.ast Struct declaration for struct being parsed
	table       &ast.Table     // v.ast table for getting type names
}

// parse_params parses struct args into struct
fn (vparser VParser) parse_vstruct(args VStructArgs) Struct {
	$if debug {
		eprintln('Parsing struct: ${args.struct_decl.name}')
	}

	comments := args.comments.map(it.text.trim_string_left('\u0001').trim_space())

	return Struct{
		name: args.struct_decl.name.all_after_last('.')
		description: comments.join(' ')
		fields: vparser.parse_fields(args.struct_decl.fields, args.table)
	}
}

struct VSumTypeArgs {
	comments     []ast.Comment   // comments that belong to the struct declaration
	sumtype_decl ast.SumTypeDecl // v.ast Struct declaration for struct being parsed
	table        &ast.Table      // v.ast table for getting type names
}

// parse_params parses struct args into struct
fn (vparser VParser) parse_vsumtype(args VSumTypeArgs) Sumtype {
	$if debug {
		eprintln('Parsing sumtype: ${args.sumtype_decl.name}')
	}

	comments := args.comments.map(it.text.trim_string_left('\u0001').trim_space())

	return Sumtype{
		name: args.sumtype_decl.name.all_after_last('.')
		description: comments.join(' ')
		types: vparser.parse_variants(args.sumtype_decl.variants, args.table)
	}
}

// parse_fields parses ast struct fields into struct fields
fn (vparser VParser) parse_fields(fields []ast.StructField, table &ast.Table) []StructField {
	mut fields_ := []StructField{}
	for field in fields {
		mut anon_struct := Struct{}
		if table.type_to_str(field.typ).all_after_last('.').starts_with('_VAnon') {
			anon_struct = vparser.parse_vstruct(
				table: table
				struct_decl: field.anon_struct_decl
			)
		}

		description := field.comments.map(it.text.trim_string_left('\u0001').trim_space()).join(' ')
		fields_ << StructField{
			name: field.name
			anon_struct: anon_struct
			description: description
			typ: Type{
				symbol: table.type_to_str(field.typ).all_after_last('.')
			}
		}
	}
	return fields_

	// return fields.map(
	// 	StructField{
	// 		name: it.name
	// 		typ: Type{
	// 			symbol: table.type_to_str(it.typ).all_after_last('.')
	// 		}
	// 	}
	// )
}

// parse_fields parses ast struct fields into struct fields
fn (vparser VParser) parse_variants(variants []ast.TypeNode, table &ast.Table) []Type {
	mut types := []Type{}
	for variant in variants {
		types << Type{
			symbol: table.type_to_str(variant.typ).all_after_last('.')
		}
	}
	return types
}
