module twinclient2

import json
// Deploy zos workload


fn new_zos(mut client TwinClient) Zos {
	// Initialize new stellar.
	return Zos{
		client: unsafe {client}
	}
}

pub fn (mut zos Zos) deploy(payload string) ?Contract {
	response := zos.client.send('zos.deploy', payload)?
	return json.decode(Contract, response.data) or {}
}
