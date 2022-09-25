module twinclient

import json
// Deploy zos workload

pub fn (mut tw Client) deploy(payload string) ?Contract {
	mut msg := tw.send('twinserver.zos.deploy', payload)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}
