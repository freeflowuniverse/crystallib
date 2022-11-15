module twinclient

import json
// Deploy zos workload


pub fn (mut client TwinClient) zos_deploy(payload string) !Contract {
	response := client.transport.send('zos.deploy', payload)!
	return json.decode(Contract, response.data) or {}
}
