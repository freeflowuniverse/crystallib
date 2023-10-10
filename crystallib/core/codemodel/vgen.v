module codemodel

import os

pub struct CodeFile {
	pub:
	mod string
	imports []Import
	items []CodeItem
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

pub fn (code CodeFile) write(params WriteCode) ! {
	code_str := vgen(code.items)
	file_str := $tmpl('./templates/code/code.v.template')
	os.mkdir_all(os.dir(params.destination))!
	os.write_file(params.destination, file_str)!
	os.execute('v fmt -w ${params.destination}')
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

// vgen_function generates a function statement for a function
pub fn (function Function) vgen() string {
	params_ := function.params.map(Param{
		...it
		typ: Type{
			symbol: if it.struct_.name != '' {
				it.struct_.name
			} else {
				it.typ.symbol
			}
		}
	})
	params := params_.map('${it.name} ${it.typ.symbol}').join(', ')

	// TODO: fix and tidy
	receiver_ := Param{
		...function.receiver
		typ: Type{
			symbol: if function.receiver.struct_.name != '' {
				function.receiver.struct_.name
			} else {function.receiver.typ.symbol}
		}
	}

	receiver := if function.receiver.name != '' {
		if function.receiver.is_shared {
			'(shared ${function.receiver.name} ${function.receiver.typ.vgen()})'
		} else {
			'(${function.receiver.name} ${function.receiver.typ.vgen()})'
		}
	} else {''}

	return $tmpl('templates/function/function.v.template')
}

// vgen_function generates a function statement for a function
pub fn (struct_ Struct) vgen() string {
	return $tmpl('templates/struct/struct.v.template')
}

pub fn (custom CustomCode) vgen() string {
	return custom.text
}

// vgen_function generates a function statement for a function
pub fn (result Result) vgen() string {
	result_type := if result.structure.name != '' {
		result.structure.name
	} else {
		result.typ.symbol
	}
	str := if result.result { '!' } else { '' }
	return '${str}${result_type}'
}
