module twinclient2

import json


fn new_machines(mut client TwinClient) Machines {
	return Machines{
		client: unsafe {client}
	}
}


// Deploy machines workload
pub fn (mut mch Machines) deploy(payload MachinesModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := mch.client.send('machines.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get machines deployment info using deployment name
pub fn (mut mch Machines) get(name string) ?[]Deployment {
	response := mch.client.send('machines.get', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Update deployed machines deployment with updated payload
pub fn (mut mch Machines) update(payload MachinesModel) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := mch.client.send('machines.update', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// List all my machines deployments
pub fn (mut mch Machines) list() ?[]string {
	response := mch.client.send('machines.list', '{}')?

	return json.decode([]string, response.data)
}

// Delete a deployed machines using deployment name
pub fn (mut mch Machines) delete(name string) ?ContractResponse {
	response := mch.client.send('machines.delete', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}

// Add new machine to a machines deployment
pub fn (mut mch Machines) add_machine(machine AddMachine) ?DeployResponse {
	payload_encoded := json.encode_pretty(machine)
	response := mch.client.send('machines.add_machine', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Delete machine from a machines deployment
pub fn (mut mch Machines) delete_machine(machine_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(machine_to_delete)
	response := mch.client.send('machines.delete_machine', payload_encoded)?

	return json.decode(ContractResponse, response.data)
}
