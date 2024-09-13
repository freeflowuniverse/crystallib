module utils

import net.http

pub fn decode_form[T] (data string) T {
	data_map := http.parse_form(data)
	mut t := T{}
	$for field in T.fields {
		if field.name in data_map {
			$if field.typ is string {
				t.$(field.name) = data_map[field.name]
			} $else $if field.typ is int {
				t.$(field.name) = int(data_map[field.name])
			}
		}
	}
	return t
}
