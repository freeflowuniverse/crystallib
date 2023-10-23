module paramsparser

import json

// pub struct ParamsPub {
// pub mut:
// 	params []Param
// 	args   []string //are commands without key/val, best not to use
// }

// pub struct ParamPub {
// pub:
// 	key   string
// 	value string
// }

pub fn (mut params Params) json_export() string {
	return json.encode(params)
}

pub fn json_import(data string) !Params {
	return json.decode(Params, data)
}
