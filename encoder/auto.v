module encoder

//example see https://github.com/vlang/v/blob/master/examples/compiletime/reflection.v

pub fn encode[T](obj T) []u8 {
	mut d:=encoder_new()
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		$if field.typ is string {
			// $(string_expr) produces an identifier
			d.add_string(obj.$(field.name))
		} $else $if field.typ is int {
			d.add_u32(u32(obj.$(field.name)))
		} $else $if field.typ is u8 {
			d.add_u8(obj.$(field.name))
		} $else $if field.typ is u16 {
			d.add_u16(obj.$(field.name))
		} $else $if field.typ is u32 {
			d.add_u32(obj.$(field.name))
		} $else $if field.typ is []string {
			d.add_list_string(obj.$(field.name))
		} $else $if field.typ is []int {
			d.add_list_int(obj.$(field.name))
		} $else $if field.typ is []u8 {
			d.add_list_u8(obj.$(field.name))
		} $else $if field.typ is []u16 {
			d.add_list_u16(obj.$(field.name))
		} $else $if field.typ is []u32 {
			d.add_list_u32(obj.$(field.name))
		} $else $if field.typ is map[string]string {
			d.add_map_string(obj.$(field.name))
		} $else $if field.typ is map[string][]u8 {
			d.add_map_bytes(obj.$(field.name))
		}
	}
	return d.data
}


pub fn decode[T](data []u8) !T {
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
