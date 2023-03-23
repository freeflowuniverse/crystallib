module tfgrid

import json

pub struct Credentials {
	mnemonics string
	network   string
}

pub fn (mut client TFGridClient) login(credentials Credentials) ! {
	res := client.rpc.call(cmd: 'login', data: json.encode(credentials))!
	if res.error != '' {
		return error(res.error)
	}
}
