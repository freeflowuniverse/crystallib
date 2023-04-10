module tfgrid

import json

pub fn (mut client TFGridClient) zos_deployment_deploy(node_id u32, deployment Deployment) ! {
	request := ZOSNodeRequest{
		node_id: node_id
		data: json.encode(deployment)
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.deployment.deploy', request)!
	_ := client.rpc.result[ZOSNodeRequest](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_system_version(node_id u32) !SystemVersion {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.system.version', request)!
	return client.rpc.result[SystemVersion](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_system_hypervisor(node_id u32) !string {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.system.hypervisor', request)!
	return client.rpc.result[string](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_system_dmi(node_id u32) !DMI {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.system.dmi', request)!
	return client.rpc.result[DMI](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_network_public_config(node_id u32) !PublicConfig {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.network.public_config_get', request)!
	return client.rpc.result[PublicConfig](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_network_interfaces(node_id u32) !map[string][]string {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.network.interfaces', request)!
	return client.rpc.result[map[string][]string](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_network_list_wg_ports(node_id u32) ![]u16 {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.network.list_wg_ports', request)!
	return client.rpc.result[[]u16](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_node_statistics(node_id u32) !Statistics {
	request := ZOSNodeRequest{
		node_id: node_id
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.statistics.get', request)!
	return client.rpc.result[Statistics](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_deployment_changes(node_id u32, contract_id u64) ![]Workload {
	request := ZOSNodeRequest{
		node_id: node_id
		data: json.encode(contract_id)
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.deployment.changes', request)!
	return client.rpc.result[[]Workload](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_deployment_update(node_id u32, deployment Deployment) ! {
	request := ZOSNodeRequest{
		node_id: node_id
		data: json.encode(deployment)
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.deployment.update', request)!
	_ := client.rpc.result[int](500000, retqueue)!
}

// this is disabled in zos, user should instead cancel their contract
pub fn (mut client TFGridClient) zos_deployment_delete(node_id u32, contract_id u64) ! {
	request := ZOSNodeRequest{
		node_id: node_id
		data: json.encode(contract_id)
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.deployment.delete', request)!
	_ := client.rpc.result[int](500000, retqueue)!
}

pub fn (mut client TFGridClient) zos_deployment_get(node_id u32, contract_id u64) !Deployment {
	request := ZOSNodeRequest{
		node_id: node_id
		data: json.encode(contract_id)
	}

	retqueue := client.rpc.call[ZOSNodeRequest]('zos.deployment.get', request)!
	return client.rpc.result[Deployment](500000, retqueue)!
}
