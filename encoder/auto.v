module encoder

import time
import x.json2 as json

// example see https://github.com/vlang/v/blob/master/examples/compiletime/reflection.v

pub fn encode[T](obj T) ![]u8 {
	mut d := encoder_new()
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		// Primitive types
		$if field.typ is string {
			// $(string_expr) produces an identifier
			d.add_string(obj.$(field.name).str())
		} $else $if field.typ is int {
			d.add_int(int(obj.$(field.name)))
		} $else $if field.typ is u8 {
			d.add_u8(u8(obj.$(field.name)))
		} $else $if field.typ is u16 {
			d.add_u16(u16(obj.$(field.name)))
		} $else $if field.typ is u32 {
			d.add_u32(u32(obj.$(field.name)))
		} $else $if field.typ is u64 {
			d.add_u64(u64(obj.$(field.name)))
		} $else $if field.typ is time.Time {
			d.add_time(time.new_time(obj.$(field.name)))
			// Arrays of primitive types
		} $else $if field.typ is []string {
			// d.add_list_string(obj.$(field.name)) why error??
			d.add_list_string(obj.$(field.name)[..])
		} $else $if field.typ is []int {
			d.add_list_int(obj.$(field.name)[..])
		} $else $if field.typ is []u8 {
			d.add_list_u8(obj.$(field.name)[..])
		} $else $if field.typ is []u16 {
			d.add_list_u16(obj.$(field.name)[..])
		} $else $if field.typ is []u32 {
			d.add_list_u32(obj.$(field.name)[..])
		} $else $if field.typ is []u64 {
			d.add_list_u64(obj.$(field.name)[..])
			// Maps of primitive types
		} $else $if field.typ is map[string]string {
			d.add_map_string(obj.$(field.name).clone())
		} $else $if field.typ is map[string][]u8 {
			d.add_map_bytes(obj.$(field.name).clone())
			// Structs
		} $else $if field.is_struct {
			e := encode(obj.$(field.name))!
			d.add_list_u8(e)
		} $else {
			typ_name := typeof(obj.$(field.name)).name
			return error("The type `${typ_name}` of field `${field.name}` can't be encoded")
		}
	}
	return d.data
}

pub fn decode[T](data []u8) !T {
	mut d := decoder_new(data)
	mut result := T{}
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	$for field in T.fields {
		// println(field.name)
		// println(typeof(result.$(field.name)).name)
		// println(result.$(field.name))

		// Primitive types
		$if field.typ is string {
			// $(string_expr) produces an identifier
			result.$(field.name) = d.get_string()
		} $else $if field.typ is int {
			result.$(field.name) = d.get_int()
		} $else $if field.typ is u8 {
			result.$(field.name) = d.get_u8()
		} $else $if field.typ is u16 {
			result.$(field.name) = d.get_u16()
		} $else $if field.typ is u32 {
			result.$(field.name) = d.get_u32()
		} $else $if field.typ is u64 {
			result.$(field.name) = d.get_u64()
		} $else $if field.typ is time.Time {
			result.$(field.name) = d.get_time()
			// Arrays of primitive types
		} $else $if field.typ is []string {
			result.$(field.name) = d.get_list_string()
		} $else $if field.typ is []int {
			result.$(field.name) = d.get_list_int()
		} $else $if field.typ is []u8 {
			result.$(field.name) = d.get_list_u8()
		} $else $if field.typ is []u16 {
			result.$(field.name) = d.get_list_u16()
		} $else $if field.typ is []u32 {
			result.$(field.name) = d.get_list_u32()
		} $else $if field.typ is []u64 {
			result.$(field.name) = d.get_list_u64()
			// Maps of primitive types
		} $else $if field.typ is map[string]string {
			result.$(field.name) = d.get_map_string()
		} $else $if field.typ is map[string][]u8 {
			result.$(field.name) = d.get_map_bytes()
			// Structs
		} $else $if field.is_struct {
			// TODO handle recursive behavior
		} $else {
			typ_name := typeof(result.$(field.name)).name
			return error("The type `${typ_name}` of field `${field.name}` can't be decoded")
		}
	}
	return result
}

// TODO: complete, the recursive behavior will be little tricky
