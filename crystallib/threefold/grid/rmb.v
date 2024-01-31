module grid

import json
import freeflowuniverse.crystallib.threefold.grid.models

// TODO: decode/encode the params/result here
pub fn (mut d Deployer) rmb_deployment_changes(dst u32, contract_id u64) !string {
	payload := json.encode({
		'contract_id': contract_id
	})
	res := d.client.rmb_call(dst, 'zos.deployment.changes', payload)!
	return res
}

pub fn (mut d Deployer) rmb_deployment_get(dst u32, data string) !string {
	res := d.client.rmb_call(dst, 'zos.deployment.get', data)!
	return res
}

pub fn (mut d Deployer) rmb_deployment_deploy(dst u32, data string) !string {
	return d.client.rmb_call(dst, 'zos.deployment.deploy', data)!
}

pub fn (mut d Deployer) rmb_deployment_update(dst u32, data string) !string {
	return d.client.rmb_call(dst, 'zos.deployment.update', data)!
}

pub fn (mut d Deployer) rmb_deployment_delete(dst u32, data string) !string {
	return d.client.rmb_call(dst, 'zos.deployment.delete', data)!
}

pub fn (mut d Deployer) get_node_pub_config(node_id u32) !models.PublicConfig {
	node_twin := d.client.get_node_twin(node_id)!
	res := d.client.rmb_call(node_twin, 'zos.network.public_config_get', '')!
	public_config := json.decode(models.PublicConfig, res)!
	return public_config
}

pub fn (mut d Deployer) assign_wg_port(node_id u32) !u16 {
	node_twin := d.client.get_node_twin(node_id)!
	taken_ports := d.client.list_wg_ports(node_twin)!
	port := models.rand_port(taken_ports) or { return error("can't assign wireguard port: ${err}") }
	return port
}
