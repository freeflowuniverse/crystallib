module params

// Decodes a params struct into a provided generic type.
pub fn (params Params) decode[T]() !T {
	// TODO: support more field types
    t := T{}
    $for field in T.fields {
        value := params.get(field.name)!
        $if field.typ is string {
            t.$(field.name) = params.get(field.name)!
        }
        $else $if field.typ is int {
            t.$(field.name) = params.get_int(field.name)!
        }
        $else $if field.typ is bool {
            t.$(field.name) = params.get_default_true(field.name)
        }       
        $else $if field.typ is []string {
            t.$(field.name) = params.get_list(field.name)!
        }       
        $else $if field.typ is []int {
            t.$(field.name) = params.get_list_int(field.name)!
        }
		$else {
			return error('Unsupported type: Params encoding and decoding for generic types only supports the following types:\nstring, int, bool, []string, []int.')
		}
    }
    return t
}

// Takes in a generic struct and type, encodes the struct into a params struct 
// with corresponding key value fields.
pub fn encode[T](t T) !Params {
    mut params := Params{}
    $for field in T.fields {
        // for some reason kwargs_add wont work so add manually
        val := t.$(field.name)
        param := Param{
            key: field.name
            value: "$val".trim_left('[').trim_right(']').replace("'","")
        }
        params.params << param
    }
    return params
}
