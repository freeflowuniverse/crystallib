module codemodel

import os
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib

pub struct CodeFile {
pub:
	name    string
	mod     string
	imports []Import
	items   []CodeItem
	content string
}

pub fn new_file(config CodeFile) CodeFile {
	return CodeFile{
		mod: config.mod
		items: config.items
	}
}

pub struct WriteCode {
	destination string
}

interface ICodeItem {
	vgen() string
}

pub fn vgen(code []CodeItem) string {
	mut str := ''
	for item in code {
		if item is Function {
			str += '\n${item.vgen()}'
		}
		if item is Struct {
			str += '\n${item.vgen()}'
		}
		if item is CustomCode {
			str += '\n${item.vgen()}'
		}
	}
	return str
}

// pub fn (code Code) vgen() string {
// 	return code.items.map(it.vgen()).join_lines()
// }

// vgen_import generates an import statement for a given type
pub fn (import_ Import) vgen() string {
	types_str := import_.types.join(', ') // comma separated string list of  types
	return 'import ${import_.mod} {${types_str}}'
}

// TODO: enfore that cant be both mutable and shared
pub fn (type_ Type) vgen() string {
	mut type_str := ''
	if type_.is_mutable {
		type_str += 'mut '
	} else if type_.is_shared {
		type_str += 'shared '
	}

	if type_.is_optional {
		type_str += '?'
	} else if type_.is_result {
		type_str += '!'
	}

	return '${type_str} ${type_.symbol}'
}

pub fn (field StructField) vgen() string {
	symbol := field.get_type_symbol()
	mut vstr := '${field.name} ${symbol}'
	if field.description != '' {
		vstr += '// ${field.description}'
	}
	return vstr
}

pub fn (field StructField) get_type_symbol() string {
	mut field_str := if field.structure.name != '' {
		field.structure.get_type_symbol()
	} else {
		field.typ.symbol
	}

	if field.is_ref {
		field_str = '&${field_str}'
	}

	return field_str
}

pub fn (structure Struct) get_type_symbol() string {
	mut symbol := if structure.mod != '' {
		'${structure.mod.all_after_last('.')}.${structure.name}'
	} else {
		structure.name
	}
	if structure.generics.len > 0 {
		symbol = '${symbol}${vgen_generics(structure.generics)}'
	}

	return symbol
}

pub fn vgen_generics(generics map[string]string) string {
	if generics.keys().len == 0 {
		return ''
	}
	mut vstr := '['
	for key, val in generics {
		vstr += if val != '' { val } else { key }
	}
	return '${vstr}]'
}

// vgen_function generates a function statement for a function
pub fn (function Function) vgen() string {
	mut params_ := function.params.map(Param{
		...it
		typ: Type{
			symbol: if it.struct_.name != '' {
				it.struct_.name
			} else {
				it.typ.symbol
			}
		}
	})

	options := params_.filter(it.is_optional)
	options_struct := Struct{
		name: '${texttools.name_fix_snake_to_pascal(function.name)}Options'
		attrs: [Attribute{
			name: 'params'
		}]
		fields: options.map(StructField{
			name: it.name
			description: it.description
			typ: Type{
				symbol: it.typ.symbol
			}
		})
	}

	if options.len > 0 {
		params_ << Param{
			name: 'options'
			typ: Type{
				symbol: options_struct.name
			}
		}
	}

	params := params_.filter(!it.is_optional).map('${it.name} ${it.typ.symbol}').join(', ')

	receiver := function.receiver.vgen()

	mut function_str := $tmpl('templates/function/function.v.template')
	result := os.execute_opt('echo "${function_str.replace('$', '\\$')}" | v fmt') or {
		panic('${function_str}\n${err}')
	}
	function_str = result.output.split_into_lines().filter(!it.starts_with('import ')).join('\n')

	return if options_struct.fields.len != 0 {
		'${options_struct.vgen()}\n${function_str}'
	} else {
		function_str
	}
}

pub fn (param Param) vgen() string {
	if param.name == '' {
		return ''
	}
	vstr := if param.struct_.name != '' {
		param.struct_.get_type_symbol()
	} else {
		param.typ.symbol
	}
	return '(${param.name} ${vstr})'
}

// vgen_function generates a function statement for a function
pub fn (struct_ Struct) vgen() string {
	gen := VGenerator{true}
	return gen.generate_struct(struct_) or { panic(err) }
	// mut struct_str := $tmpl('templates/struct/struct.v.template')
	// return struct_str
	// result := os.execute_opt('echo "${struct_str.replace('$', '\$')}" | v fmt') or {panic(err)}
	// return result.output
}

pub struct VGenerator {
	format bool
}

pub fn (gen VGenerator) generate_struct(struct_ Struct) !string {
	name := if struct_.generics.len > 0 {
		println('struct  ${struct_}')
		'${struct_.name}${vgen_generics(struct_.generics)}'
	} else {
		struct_.name
	}
	priv_fields := struct_.fields.filter(!it.is_mut && !it.is_pub).map(gen.generate_struct_field(it))
	pub_fields := struct_.fields.filter(!it.is_mut && it.is_pub).map(gen.generate_struct_field(it))
	mut_fields := struct_.fields.filter(it.is_mut && !it.is_pub).map(gen.generate_struct_field(it))
	pub_mut_fields := struct_.fields.filter(it.is_mut && it.is_pub).map(gen.generate_struct_field(it))

	mut struct_str := $tmpl('templates/struct/struct.v.template')
	if gen.format {
		result := os.execute_opt('echo "${struct_str.replace('$', '\$')}" | v fmt') or {
			println(struct_str)
			panic(err)
		}
		return result.output
	}
	return struct_str
}

pub fn (gen VGenerator) generate_struct_field(field StructField) string {
	symbol := field.get_type_symbol()
	mut vstr := '${field.name} ${symbol}'
	if field.description != '' {
		vstr += '// ${field.description}'
	}
	return vstr
}

pub fn (custom CustomCode) vgen() string {
	return custom.text
}

// vgen_function generates a function statement for a function
pub fn (result Result) vgen() string {
	result_type := if result.structure.name != '' {
		result.structure.get_type_symbol()
	} else {
		result.typ.symbol
	}
	str := if result.result { '!' } else { '' }
	return '${str}${result_type}'
}

@[params]
pub struct WriteOptions {
	format    bool
	overwrite bool
}

pub fn (mod Module) write_v(path string, options WriteOptions) ! {
	dir := pathlib.get_dir(path: path, create: true, empty: options.overwrite)!
	for name, codefile in mod.files {
		codefile.write_v(dir.path, options)!
	}
}

pub fn (code CodeFile) write_v(path string, options WriteOptions) ! {
	filename := '${texttools.name_fix(code.name)}.v'
	mut filepath := pathlib.get('${path}/${filename}')

	if !options.overwrite && filepath.exists() {
		return
	}

	file_str := if code.content != '' {
		code.content
	} else {
		code_str := vgen(code.items)
		$tmpl('./templates/code/code.v.template')
	}

	mut file := pathlib.get_file(
		path: filepath.path
		create: true
	)!
	file.write(file_str)!
	if options.format {
		os.execute('v fmt -w ${file.path}')
	}
}
