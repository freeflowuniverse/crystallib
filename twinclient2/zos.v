module twinclient2

import json
// Deploy zos workload

pub fn (mut tw TwinClient) deploy(payload string) ?Contract {
	response := tw.send('zos.deploy', payload)?
	return json.decode(Contract, response.data) or {}
}
