module twinclient2

import json


// Deploy machines workload
pub fn (mut client TwinClient) machines_deploy(payload MachinesModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('machines.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get machines deployment info using deployment name
pub fn (mut client TwinClient) machines_get(name string) ?[]Deployment {
	response := client.send('machines.get', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Update deployed machines deployment with updated payload
pub fn (mut client TwinClient) machines_update(payload MachinesModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('machines.update', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// List all my machines deployments
pub fn (mut client TwinClient) machines_list() ?[]string {
	response := client.send('machines.list', '{}')?

	return json.decode([]string, response.data)
}

// Delete a deployed machines using deployment name
pub fn (mut client TwinClient) machines_delete(name string) ?ContractResponse {
	response := client.send('machines.delete', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}

// Add new machine to a machines deployment
pub fn (mut client TwinClient) machines_add_machine(machine AddMachine) ?DeployResponse {
	payload_encoded := json.encode_pretty(machine)
	response := client.send('machines.add_machine', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Delete machine from a machines deployment
pub fn (mut client TwinClient) machines_delete_machine(machine_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(machine_to_delete)
	response := client.send('machines.delete_machine', payload_encoded)?

	return json.decode(ContractResponse, response.data)
}
