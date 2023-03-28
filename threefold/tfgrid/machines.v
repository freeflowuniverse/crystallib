module tfgrid

import json

// Deploy machines workload
pub fn (mut client TFGridClient) machines_deploy(deployment MachinesModel) !MachinesResult {
	payload_encoded := json.encode_pretty(deployment)
	result := client.rpc.call(cmd: 'machines.deploy', data: payload_encoded)!
	return json.decode(MachinesResult, result)
}

// Get machines deployment info using deployment name
pub fn (mut client TFGridClient) machines_get(name string) !MachinesResult {
	result := client.rpc.call(
		cmd: 'machines.get'
		data: name
	)!
	return json.decode(MachinesResult, result)
}

// Delete a deployed machines using project name
pub fn (mut client TFGridClient) machines_delete(name string) ! {
	client.rpc.call(
		cmd: 'machines.delete'
		data: name
	)!
}

// Add new machine to a machines deployment
pub fn (mut client TFGridClient) machines_add_machine(add_machine AddMachine) !MachinesResult {
	payload_encoded := json.encode_pretty(add_machine)
	result := client.rpc.call(cmd: 'machines.machine.add', data: payload_encoded)!
	return json.decode(MachinesResult, result)
}

// // Delete machine from a machines deployment
pub fn (mut client TFGridClient) machines_delete_machine(remove_machine RemoveMachine) !MachinesResult {
	payload_encoded := json.encode_pretty(remove_machine)
	result := client.rpc.call(cmd: 'machines.machine.remove', data: payload_encoded)!
	return json.decode(MachinesResult, result)
}