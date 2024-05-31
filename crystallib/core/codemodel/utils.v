module codemodel

import rand

pub struct GetStruct {
	code []CodeItem
	mod  string
	name string
}

pub fn get_struct(params GetStruct) ?Struct {
	structs_ := params.code.filter(it is Struct).map(it as Struct)
	structs := structs_.filter(it.name == params.name)
	if structs.len == 0 {
		return none
	} else if structs.len > 1 {
		panic('Multiple structs with same name found. This should never happen.')
	}
	return structs[0]
}

pub fn inflate_types(mut code []CodeItem) {
	for mut item in code {
		if item is Struct {
			// TODO: handle this when refactoring types / structs

			inflate_struct_fields(code, mut item)
		}
	}
}

pub fn inflate_struct_fields(code []CodeItem, mut struct_ CodeItem) {
	for mut field in (struct_ as Struct).fields {
		// TODO: fix inflation for imported types
		if field.typ.symbol.starts_with_capital() {
			field.structure = get_struct(
				code: code
				name: field.typ.symbol
			) or { continue }
		}
	}
}

@[params]
pub struct GenerateCallParams {
	receiver string
}

pub fn (func Function) generate_call(params GenerateCallParams) !string {
	mut call := ''
	if func.result.typ.symbol != '' {
		call = 'result := '
	}
	call += if params.receiver != '' {'${params.receiver}.${func.name}'} else if func.receiver.name != '' {'${func.receiver.name}.${func.name}'
	} else {func.name}

	call += if func.params.len != 0 {
		"(${func.params.map(it.generate_value()!).join(',')})"
	} else {'()'}

	if func.result.result {
		call += '!'
	}
	return call
}

@[params]
pub struct GenerateValueParams {

}

pub fn (param Param) generate_value() !string {
	if param.typ.symbol == 'string' {
		return "'mock_string_${rand.string(3)}'"
	} else if param.typ.symbol == 'int' || param.typ.symbol == 'u32'{
		return '42'
	} else if param.typ.symbol[0].is_capital() {
		return '${param.typ.symbol}{}'
	} else {
		println('mock values for types other than strings and ints are not yet supported')
	}	
	return ''
}