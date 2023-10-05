module codemodel

struct Code {
	items []ICodeItem
}

pub fn new(items []ICodeItem) Code {
	return Code{items:items}
}

interface ICodeItem {
	vgen() string
}

pub fn (code Code) vgen() string {
	return code.items.map(it.vgen()).join_lines()
}

// vgen_import generates an import statement for a given type
pub fn (import_ Import) vgen() string {
	types_str := import_.types.join(', ') // comma separated string list of  types
	return 'import ${import_.mod} {${types_str}}'
}

// vgen_function generates a function statement for a function
pub fn (function Function) vgen() string {
	params_ := function.params.map(
		Param{
			...it
			typ: Type{symbol:it.struct_.name}
		}
	)
	params := params_.map('${it.name} ${it.typ.symbol}').join(', ')
	
	// TODO: fix and tidy
	receiver_ := Param{...function.receiver
		typ: Type{symbol:function.receiver.struct_.name}
	}



	receiver := if function.receiver.name != '' {
		mut_ := if function.receiver.mutable { 'mut ' } else { '' }
		'(${mut_}${function.receiver.name} ${receiver_.typ.symbol})'
	} else {
		''
	}

	return $tmpl('templates/function/function.v.template')
}

// vgen_function generates a function statement for a function
pub fn (struct_ Struct) vgen() string {
	return $tmpl('templates/struct/struct.v.template')
}

// vgen_function generates a function statement for a function
pub fn (result Result) vgen() string {
	str := if result.result {'!'} else {''}
	return str
}
