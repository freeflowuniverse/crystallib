module tfgrid

// Deploy machines workload
pub fn (mut client TFGridClient) machines_deploy(deployment MachinesModel) !MachinesResult {
	retqueue := client.rpc.call[MachinesModel]('tfgrid.machines.deploy', deployment)!
	return client.rpc.result[MachinesResult](5000, retqueue)!
}

// Get machines deployment info using deployment name
pub fn (mut client TFGridClient) machines_get(name string) !MachinesResult {
	retqueue := client.rpc.call[string]('tfgrid.machines.get', name)!
	return client.rpc.result[MachinesResult](5000, retqueue)!
}

// Delete a deployed machines using project name
pub fn (mut client TFGridClient) machines_delete(name string) ! {
	retqueue := client.rpc.call[string]('tfgrid.machines.delete', name)!
	client.rpc.result[MachinesResult](5000, retqueue)!
}

// Add new machine to a machines deployment
pub fn (mut client TFGridClient) machines_add_machine(add_machine AddMachine) !MachinesResult {
	retqueue := client.rpc.call[AddMachine]('tfgrid.machine.add', add_machine)!
	return client.rpc.result[MachinesResult](5000, retqueue)!
}

// // Delete machine from a machines deployment
pub fn (mut client TFGridClient) machines_delete_machine(remove_machine RemoveMachine) !MachinesResult {
	retqueue := client.rpc.call[RemoveMachine]('tfgrid.machine.remove', remove_machine)!
	return client.rpc.result[MachinesResult](5000, retqueue)!
}
