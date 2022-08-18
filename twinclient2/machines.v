module twinclient2

import json

// Deploy machines workload
pub fn (mut tw TwinClient) deploy_machines(payload Machines) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('machines.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Get machines deployment info using deployment name
pub fn (mut tw TwinClient) get_machines(name string) ?[]Deployment {
	response := tw.send('machines.get', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// Update deployed machines deployment with updated payload
pub fn (mut tw TwinClient) update_machines(payload Machines) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('machines.update', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// List all my machines deployments
pub fn (mut tw TwinClient) list_machines() ?[]string {
	response := tw.send('machines.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Delete a deployed machines using deployment name
pub fn (mut tw TwinClient) delete_machines(name string) ?ContractResponse {
	response := tw.send('machines.delete', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}

// Add new machine to a machines deployment
pub fn (mut tw TwinClient) add_machine(machine AddMachine) ?DeployResponse {
	payload_encoded := json.encode_pretty(machine)
	response := tw.send('machines.add_machine', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Delete machine from a machines deployment
pub fn (mut tw TwinClient) delete_machine(machine_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(machine_to_delete)
	response := tw.send('machines.delete_machine', payload_encoded)?

	return json.decode(ContractResponse, response.data) or {}
}
