module encoderhero

import time
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools

pub struct Decoder[T] {
pub mut:
	object T
	data string
}

pub fn decode[T](data string) !T {
	return decode_struct[T](T{}, data)
}


// decode_struct is a generic function that decodes a JSON map into the struct T.
fn decode_struct[T](_ T, data string) !T {
	mut typ := T{}

	$if T is $struct  {
		obj_name := texttools.name_fix_pascal_to_snake(T.name.all_after_last('.'))
		action_name := 'define.${obj_name}'
		actions_split := data.split('!!')
		actions := actions_split.filter(it.starts_with(action_name))

		mut action_str := ''
		// action_str := '!!define.${obj_name}'
		if actions.len == 0 {return T{}}
		else {
			action_str = actions[0]
			params_str := action_str.trim_string_left(action_name)
			params := paramsparser.parse(params_str)!
			typ = params.decode[T]()!
		}
		// panic('debuggge ${t_}\n${actions[0]}')
		
		// return t_
		$for field in T.fields {
			// $if fiel
			$if field.is_struct {
				$if field.typ !is time.Time {
					if !field.name[0].is_capital() {
						// skip embedded ones
						mut data_fmt := data.replace(action_str, '')
						data_fmt = data.replace('define.${obj_name}', 'define')
						typ.$(field.name) = decode_struct(typ.$(field.name), data_fmt)!
					}
				}
			} $else $if field.is_array {
				mut data_fmt := data.replace(action_str, '')
				data_fmt = data.replace('define.${obj_name}', 'define')
				arr := decode_array(typ.$(field.name), data_fmt)!
				typ.$(field.name) = arr
			}
		}
	} $else {
		return error("The type `${T.name}` can't be decoded.")
	}
	return typ
}

pub fn decode_array[T](_ []T, data string) ![]T {
	mut arr := []T{}
	// for i in 0 .. val.len {
		value := T{}
		$if T is $struct {
			arr << decode_struct(value, data)!
		}
	// }
	return arr
}