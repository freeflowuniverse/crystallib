module encoderhero

import freeflowuniverse.crystallib.data.paramsparser
import time
import v.reflection
import freeflowuniverse.crystallib.data.ourtime

// Encoder encodes the an `Any` type into HEROSCRIPT representation.
// It provides parameters in order to change the end result.
pub struct Encoder {
pub mut:
	escape_unicode bool = true
	action_name    string
	action_names   []string
	params         paramsparser.Params
	children       []Encoder
	parent         ?&Encoder           @[skip; str: skip]
}

// encode is a generic function that encodes a type into a HEROSCRIPT string.
pub fn encode[T](val T) !string {
	mut e := Encoder{
		params: paramsparser.Params{}
	}

	$if T is $struct {
		e.encode_struct[T](val)!
	} $else $if T is []$struct {
		e.add_child_list[T](val,"TODO")
	} $else {
		return error('can only add elements for struct or array of structs. \n${val}')
	}

	println('main: \n${e.children}\n')
	return e.export()!
}

// export exports an encoder into encoded heroscript
pub fn (e Encoder) export() !string {
	mut script := e.params.export(pre: '!!define.${e.action_names.join('.')}')
	script += e.children.map(it.export()!).join('\n')
	return script
}

// needs to be a struct we are adding
// parent is the name of the action e.g define.customer:contact
pub fn (mut e Encoder) add_child[T](val T,parent string) ! {
	$if T is []$struct {
		mut counter:=0
		for valitem in val{
			mut e2:=e.add_child[T](valitem,"${parent}:${counter}")!
		}
		return	
	}
	mut e2 := Encoder{
		params: paramsparser.Params{}
		parent: &e
		action_names: e.action_names
	}
	$if T is $struct {
		e2.params.set('key', parent)
		e2.encode_struct[T](val)!
		e.children << e2
	} $else {
		return error('can only add elements for struct or array of structs. \n${val}')
	}
}

pub fn (mut e Encoder) add_child_list[U](val []U, parent string) ! {
	for i in 0 .. val.len {
		mut counter:=0
		$if U is $struct {
			e.add_child(val[i],"${parent}:${counter}")!
			counter+=1
		}
	}
}

// now encode the struct
pub fn (mut e Encoder) encode_struct[T](t T) ! {
	mut mytype := reflection.type_of[T](t)
	struct_attrs := attrs_get_reflection(mytype)

	mut action_name := T.name.to_lower().all_after_last('.')
	if 'alias' in struct_attrs {
		action_name = struct_attrs['alias'].to_lower()
	}
	e.action_names << action_name

	params := paramsparser.encode[T](t,recursive=false)!
	e.params = params
	$for field in T.fields {
		val := t.$(field.name)
		$if val is time.Time {
			// e.add(val)!
			panic("time not supported")
		} $else $if val is ourtime.OurTime {
			panic("ourtime not supported")
			// e.add(val)!
		} $else $if val is $struct {
			e.add_child(val)!
		} $else $if val is $array {
			e.encode_array(val)!
		} $else {
			return error("can't encode to hero.\n${t}")
		}
	}
	// }
	// panic(params)

	// $for field in T.fields {
	// 	val := val0.$(field.name)

	// 	field_attrs := attrs_get(field.attrs)
	// 	mut field_name := field.name
	// 	if 'alias' in field_attrs {
	// 		field_name = field_attrs['alias']
	// 	}
	// 	println('FIELD: ${field_name} ${field.typ}')

	// 	e.encode_value(val, field_name)!
	// }
}

// encode_value encodes a value
pub fn (mut e Encoder) encode_value[T](val T, key string) ! {
	// $if val is $option {
	// 	// unwrap and encode optionals
	// 	workaround := val
	// 	if workaround != none {
	// 		e.encode_value(val, key)!
	// 	}
	// }

	//  $else $if T is string || T is int || T is bool || T is i64 || T is time.Time{
	// 	e.params.set(key, '${val}')
	// } $else $if T is []string {
	// 	mut v2 := ''
	// 	for i in val {
	// 		if i.contains(' ') {
	// 			v2 += "\"${i}\","
	// 		} else {
	// 			v2 += '${i},'
	// 		}
	// 	}
	// 	v2 = v2.trim(',')
	// 	e.params.set(key, '${v2}')
	// } $else $if T is []int {
	// 	mut v2 := ''
	// 	for i in val {
	// 		v2 += '${i},'
	// 	}
	// 	v2 = v2.trim(',')
	// 	e.params.set(key, v2.str())
	// }
	// $else $if field.typ $enum {
	// 	e.params.set( field.name,v2.str())
	// }
	// $else $if T is $struct{
	// 	e.add(val)!
	// } $else {
	// 	return error("can't find field type ${typeof(val)}")
	// }
}

// fn (e &Encoder) encode_map[T](value T, level int) ! {
// 	params << json2.curly_open_rune
// 	mut idx := 0
// 	for k, v in value {
// 		e.encode_newline(level, mut params)!
// 		// e.encode_string(k.str(), mut params)!
// 		e.encode_string(k, mut params)!
// 		params << json2.colon_rune
// 		if e.newline != 0 {
// 			params << ` `
// 		}

// 		// workaround to avoid `cannot convert 'struct x__json2__Any' to 'struct string'`
// 		$if v is $sumtype {
// 			$for variant_value in v.variants {
// 				if v is variant_value {
// 					e.encode_value_with_level(v, level + 1, mut params)!
// 				}
// 			}
// 		} $else {
// 			e.encode_value_with_level(v, level + 1, mut params)!
// 		}

// 		if idx < value.len - 1 {
// 			params << json2.comma_rune
// 		}
// 		idx++
// 	}
// 	// e.encode_newline(level, mut params)!
// 	e.encode_newline(level - 1, mut params)!
// 	params << json2.curly_close_rune
// }

// fn (e &Encoder) encode_value_with_level[T](val T) ! {
// 	$if val is $option {
// 		workaround := val
// 		if workaround != none {
// 			e.encode_value_with_level(val, level, mut params)!
// 		}
// 	} $else $if T is string {
// 		e.encode_string(val, mut params)!
// 	} $else $if T is $sumtype {
// 		$for v in val.variants {
// 			if val is v {
// 				e.encode_value_with_level(val, level, mut params)!
// 			}
// 		}
// 	} $else $if T is $alias {
// 		// TODO
// 	} $else $if T is time.Time {
// 		str_value := val.format_rfc3339()
// 		params << json2.quote_rune
// 		unsafe { params.push_many(str_value.str, str_value.len) }
// 		params << json2.quote_rune
// 	} $else $if T is $map {
// 		e.encode_map(val, level, mut params)!
// 	} $else $if T is $array {
// 		e.encode_array(val, level, mut params)!
// 	} $else $if T is Encodable {
// 		str_value := val.json_str()
// 		unsafe { params.push_many(str_value.str, str_value.len) }
// 	} $else $if T is Null {
// 		unsafe { params.push_many(json2.null_in_bytes.str, json2.null_in_bytes.len) }
// 	} $else $if T is $struct {
// 		e.encode_struct(val, level, mut params)!
// 	} $else $if T is $enum {
// 		str_int := int(val).str()
// 		unsafe { params.push_many(str_int.str, str_int.len) }
// 	} $else $if T is $int || T is $float || T is bool {
// 		str_int := val.str()
// 		unsafe { params.push_many(str_int.str, str_int.len) }
// 	} $else {
// 		return error('cannot encode value with ${typeof(val).name} type')
// 	}
// }

// fn (e &Encoder) encode_struct[U](val U) ! {
// 	mut i := 0
// 	mut fields_len := 0

// 	$for field in U.fields {
// 		mut @continue := false
// 		for attr in field.attrs {
// 			if attr.contains('json: ') {
// 				if attr.replace('json: ', '') == '-' {
// 					@continue = true
// 				}
// 				break
// 			}
// 		}
// 		if !@continue {
// 			$if field.is_option {
// 				if val.$(field.name) != none {
// 					fields_len++
// 				}
// 			} $else {
// 				fields_len++
// 			}
// 		}
// 	}
// 	$for field in U.fields {
// 		mut ignore_field := false

// 		value := val.$(field.name)

// 		is_nil := val.$(field.name).str() == '&nil'

// 		mut json_name := ''

// 		for attr in field.attrs {
// 			if attr.contains('json: ') {
// 				json_name = attr.replace('json: ', '')
// 				if json_name == '-' {
// 					ignore_field = true
// 				}
// 				break
// 			}
// 		}

// 		if !ignore_field {
// 			$if value is $option {
// 				workaround := val.$(field.name)
// 				if workaround != none { // smartcast
// 					e.encode_newline(level, mut params)!
// 					if json_name != '' {
// 						e.encode_string(json_name, mut params)!
// 					} else {
// 						e.encode_string(field.name, mut params)!
// 					}
// 					params << json2.colon_rune

// 					if e.newline != 0 {
// 						params << ` `
// 					}
// 					e.encode_value_with_level(value, level, mut params)!
// 				} else {
// 					ignore_field = true
// 				}
// 			} $else {
// 				is_none := val.$(field.name).str() == 'unknown sum type value' // assert json.encode(StructType[SumTypes]{}) == '{}'
// 				if !is_none && !is_nil {
// 					e.encode_newline(level, mut params)!
// 					if json_name != '' {
// 						e.encode_string(json_name, mut params)!
// 					} else {
// 						e.encode_string(field.name, mut params)!
// 					}
// 					params << json2.colon_rune

// 					if e.newline != 0 {
// 						params << ` `
// 					}
// 				}

// 				$if field.indirections != 0 {
// 					if val.$(field.name) != unsafe { nil } {
// 						$if field.indirections == 1 {
// 							e.encode_value_with_level(*val.$(field.name), level + 1, mut
// 								params)!
// 						}
// 						$if field.indirections == 2 {
// 							e.encode_value_with_level(**val.$(field.name), level + 1, mut
// 								params)!
// 						}
// 						$if field.indirections == 3 {
// 							e.encode_value_with_level(***val.$(field.name), level + 1, mut
// 								params)!
// 						}
// 					}
// 				} $else $if field.typ is string {
// 					e.encode_string(val.$(field.name).str(), mut params)!
// 				} $else $if field.typ is time.Time {
// 					str_value := val.$(field.name).format_rfc3339()
// 					params << json2.quote_rune
// 					unsafe { params.push_many(str_value.str, str_value.len) }
// 					params << json2.quote_rune
// 				} $else $if field.typ is bool {
// 					if value {
// 						unsafe { params.push_many(json2.true_in_string.str, json2.true_in_string.len) }
// 					} else {
// 						unsafe { params.push_many(json2.false_in_string.str, json2.false_in_string.len) }
// 					}
// 				} $else $if field.typ in [$float, $int] {
// 					str_value := val.$(field.name).str()
// 					unsafe { params.push_many(str_value.str, str_value.len) }
// 				} $else $if field.is_array {
// 					// TODO: replace for `field.typ is $array`
// 					e.encode_array(value, level + 1, mut params)!
// 				} $else $if field.typ is $array {
// 					// e.encode_array(value, level + 1, mut params)! // FIXME: error: could not infer generic type `U` in call to `encode_array`
// 				} $else $if field.typ is $struct {
// 					e.encode_struct(value, level + 1, mut params)!
// 				} $else $if field.is_map {
// 					e.encode_map(value, level + 1, mut params)!
// 				} $else $if field.is_enum {
// 					// TODO: replace for `field.typ is $enum`
// 					// str_value := int(val.$(field.name)).str()
// 					// unsafe { params.push_many(str_value.str, str_value.len) }
// 					e.encode_value_with_level(val.$(field.name), level + 1, mut params)!
// 				} $else $if field.typ is $enum {
// 				} $else $if field.typ is $sumtype {
// 					field_value := val.$(field.name)
// 					if field_value.str() != 'unknown sum type value' {
// 						$for v in field_value.variants {
// 							if field_value is v {
// 								e.encode_value_with_level(field_value, level, mut params)!
// 							}
// 						}
// 					}
// 				} $else $if field.typ is $alias {
// 					$if field.unaliased_typ is string {
// 						e.encode_string(val.$(field.name).str(), mut params)!
// 					} $else $if field.unaliased_typ is time.Time {
// 						parsed_time := time.parse(val.$(field.name).str()) or { time.Time{} }
// 						e.encode_string(parsed_time.format_rfc3339(), mut params)!
// 					} $else $if field.unaliased_typ is bool {
// 						if val.$(field.name) {
// 							unsafe { params.push_many(json2.true_in_string.str, json2.true_in_string.len) }
// 						} else {
// 							unsafe { params.push_many(json2.false_in_string.str, json2.false_in_string.len) }
// 						}
// 					} $else $if field.unaliased_typ in [$float, $int] {
// 						str_value := val.$(field.name).str()
// 						unsafe { params.push_many(str_value.str, str_value.len) }
// 					} $else $if field.unaliased_typ is $array {
// 						// TODO
// 					} $else $if field.unaliased_typ is $struct {
// 						e.encode_struct(value, level + 1, mut params)!
// 					} $else $if field.unaliased_typ is $enum {
// 						// TODO
// 					} $else $if field.unaliased_typ is $sumtype {
// 						// TODO
// 					} $else {
// 						return error('the alias ${typeof(val).name} cannot be encoded')
// 					}
// 				} $else {
// 					return error('type ${typeof(val).name} cannot be array encoded')
// 				}
// 			}
// 		}

// 		if i < fields_len - 1 && !ignore_field {
// 			if !is_nil {
// 				params << json2.comma_rune
// 			}
// 		}
// 		if !ignore_field {
// 			i++
// 		}
// 	}
// 	e.encode_newline(level - 1, mut params)!
// 	params << json2.curly_close_rune
// 	// b.measure('encode_struct')
// }

// fn (e &Encoder) encode_array[U](val []U, level int) ! {
// 	if val.len == 0 {
// 		unsafe { params.push_many(&json2.empty_array[0], json2.empty_array.len) }
// 		return
// 	}
// 	params << `[`
// 	for i in 0 .. val.len {
// 		e.encode_newline(level, mut params)!

// 		$if U is string || U is bool || U is $int || U is $float {
// 			e.encode_value_with_level(val[i], level + 1, mut params)!
// 		} $else $if U is $array {
// 			e.encode_array(val[i], level + 1, mut params)!
// 		} $else $if U is $struct {
// 			e.encode_struct(val[i], level + 1, mut params)!
// 		} $else $if U is $sumtype {
// 			e.encode_value_with_level(val[i], level + 1, mut params)!
// 		} $else $if U is $enum {
// 			// TODO: test
// 			e.encode_value_with_level(val[i], level + 1, mut params)!
// 		} $else {
// 			return error('type ${typeof(val).name} cannot be array encoded')
// 		}
// 		if i < val.len - 1 {
// 			params << json2.comma_rune
// 		}
// 	}

// 	e.encode_newline(level - 1, mut params)!
// 	params << `]`
// }
