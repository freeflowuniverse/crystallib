module paramsparser

import v.reflection
// TODO: support more field types

pub fn (params Params) decode[T]() !T {
	mut t := T{}
	$for field in T.fields {
		// value := params.get(field.name)!
		$if field.typ is string {
			t.$(field.name) = params.get(field.name)!
		}
		$if field.typ is int {
			t.$(field.name) = params.get_int(field.name)!
		}
		$if field.typ is bool {
			t.$(field.name) = params.get_default_true(field.name)
		}
		$if field.typ is []string {
			t.$(field.name) = params.get_list(field.name)!
		}
		$if field.typ is []int {
			// println(params.get_list_int(field.name)!)
			t.$(field.name) = params.get_list_int(field.name)!
		}
	}
	return t
}

pub fn encode[T](t T) !Params {
	mut params := Params{}

	mut mytype := reflection.type_of[T](t)

	struct_attrs := attrs_get_reflection(mytype)

	$for field in T.fields {
		field_attrs := attrs_get(field.attrs)
		println(field.name)
		println(field.typ)
		println(field_attrs)
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
		} $else $if field.typ is $struct {
			println(field.typ)
			panic('s')
		} $else {
		}
	}
	return params
}

// BACKLOG: can we do the encode recursive?
