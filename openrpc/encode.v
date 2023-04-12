module openrpc

import json
import x.json2 {Any}
import v.reflection

// encode encodes an OpenRPC document struct into json string.
// eliminates undefined variable by calling prune on the initial encoding.
pub fn (doc OpenRPC) encode() !string {
	encoded := json.encode(doc)
	raw_decode := json2.raw_decode(encoded)!
	mut doc_map := raw_decode.as_map()
	return prune(doc_map).str()
}

// prune recursively prunes a map of Any type, pruning map keys where the value is the default value of the variable.
// this treats undefined values as null, which is ok for openrpc document encoding.
pub fn prune(obj Any) Any {
	mut pruned := Any{}
	
	if obj is map[string]Any {
		mut pruned_map := map[string]Any{}

		for key, val in obj as map[string]Any {
			if key == '_type' {
				continue
			}
			pruned_val := prune(val)
			if pruned_val.str() != '' {
				pruned_map[key] = pruned_val
			} else if key == 'methods' || key == 'params' {
				pruned_map[key] = []Any{}
			}
		}

		if pruned_map.keys().len != 0 {
			return pruned_map
		}
	} else if obj is []Any {
		mut pruned_arr := []Any{}

		for val in obj as []Any {
			pruned_val := prune(val)
			if pruned_val.str() != '' {
				pruned_arr << pruned_val
			}
		}

		if pruned_arr.len != 0 {
			return pruned_arr
		}
	} else if obj is string {
		if obj != '' {
			return obj
		}
	}
	return ''
}