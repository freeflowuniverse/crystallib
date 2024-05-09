module encoderhero

import time
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools

// encode is a generic function that encodes a type into a HEROSCRIPT string.
pub fn decode[T](data string) !T {
	action_str := '!!define.${texttools.name_fix(T.name.all_after_last('.'))}'
	params := paramsparser.parse(data.trim_string_left(action_str))!
	return params.decode[T]()
}
