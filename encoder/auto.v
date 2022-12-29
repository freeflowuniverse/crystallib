module encoder

//example see https://github.com/vlang/v/blob/master/examples/compiletime/reflection.v

pub fn encode[T](obj T) {
	mut d:=encode_new()
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		$if field.typ is string {
			// $(string_expr) produces an identifier
			d.add_string(obj.$(field.name))
		} $else $if field.typ is int {
			d.add_int(obj.$(field.name))
		}
	}
	return result
}


pub fn decode[T](data []u8) T {
	mut d:=decoder_new(data)
	mut result := T{}
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		$if field.typ is string {
			// $(string_expr) produces an identifier
			result.$(field.name) = d.get_string()
		} $else $if field.typ is int {
			result.$(field.name) = d.get_int()
		}
	}
	return result
}

//TODO: complete, the recursive behavior will be little tricky
