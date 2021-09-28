module twinclient

import json

pub fn (mut tw Client) deploy(payload string) ?Contract {
	/*
	Deploy zos workload
		Input:
			- payload (string): zos payload + node_id
		Output:
			- Contract: new Contract instance with all contract info.
	*/
	mut msg := tw.send('twinserver.zos.deploy', payload) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}
