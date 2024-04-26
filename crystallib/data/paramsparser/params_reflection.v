module paramsparser

import v.reflection
// TODO: support more field types

pub fn (params Params) decode[T]() !T {
	// work around to allow recursive decoding
	// otherwise v cant infer generic type for child fields that are structs
	return params.decode_struct[T](T{})!
}

pub fn (params Params) decode_struct[T](_ T) !T {
	mut t := T{}
	$for field in T.fields {
		// value := params.get(field.name)!
		$if field.typ is string {
			t.$(field.name) = params.get(field.name)!
		}
		$if field.typ is int  {
			t.$(field.name) = params.get_int(field.name)!
		}
		$if field.typ is f64 || field.typ is f32 {
			t.$(field.name) = params.get_float(field.name)!
		}		
		$if field.typ is bool {
			t.$(field.name) = params.get_default_true(field.name)
		}
		$if field.typ is []string {
			t.$(field.name) = params.get_list(field.name)!
		}
		$if field.typ is []int {
			t.$(field.name) = params.get_list_int(field.name)!
		}
		$if field.typ is $struct {
			child_params := params.get_params(field.name)!
			child := child_params.decode_struct(t.$(field.name))!
			t.$(field.name) = child
		}
	}
	return t
}

@[params]
pub struct EncodeArgs{
pub:
	recursive bool = true
}

pub fn encode[T](t T, args EncodeArgs) !Params {
	mut params := Params{}

	mut mytype := reflection.type_of[T](t)

	// struct_attrs := attrs_get_reflection(mytype)

	$for field in T.fields {
		// field_attrs := attrs_get(field.attrs)
		// println(field.name)
		// println(field.typ)
		// println(field_attrs)
		val := t.$(field.name)
		$if field.typ is string {
			params.params << Param{
				key: field.name
				value: '${val}'
			}
		} $else $if field.typ is int {
			params.params << Param{
				key: field.name
				value: '${val}'
			}
		} $else $if field.typ is f64 {
			params.params << Param{
				key: field.name
				value: '${val}'
			}			
		} $else $if field.typ is bool {
			if val {
				params.params << Param{
					key: field.name
					value: 'true'
				}
			} else {
				params.params << Param{
					key: field.name
					value: 'false'
				}
			}
		} $else $if field.typ is []string {
			mut v2 := ''
			for i in val {
				if i.contains(' ') {
					v2 += "\"${i}\","
				} else {
					v2 += '${i},'
				}
			}
			v2 = v2.trim(',')
			params.params << Param{
				key: field.name
				value: v2
			}
		} $else $if field.typ is []int {
			mut v2 := ''
			for i in val {
				v2 += '${i},'
			}
			v2 = v2.trim(',')
			params.params << Param{
				key: field.name
				value: v2
			}
		} $else $if field.typ is []f64 {
			mut v2 := ''
			for i in val {
				v2 += '${i},'
			}
			v2 = v2.trim(',')
			params.params << Param{
				key: field.name
				value: v2
			}			
		} $else $if field.typ is $struct {
			if args.recursive{
				child_params := encode(val)!
				params.params << Param{
					key: field.name
					value: child_params.export()
				}
			}
		} $else {
		}
	}
	return params
}


