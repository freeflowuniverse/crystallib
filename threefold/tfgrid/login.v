module tfgrid

import json

pub struct Credentials {
	mnemonics string
	network   string // TODO: that should not be a string, work with enum, check enum inside login
}

pub fn (mut client TFGridClient) login(credentials Credentials) ! {
	res := client.rpc.call(cmd: 'login', data: json.encode(credentials))!
	if res.error != '' {
		return error(res.error)
	}
}
