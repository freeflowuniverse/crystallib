module tfgrid

import os
import json
import models

pub fn (mut d Deployer) rmb_deployment_changes(dst u32, contract_id u64) !string {
	res := os.execute("grid-cli rmb-dl-changes --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --relay ${d.relay_url} --dst ${dst} --contract_id '${contract_id}'")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return res.output
}

pub fn (mut d Deployer) rmb_deployment_get(dst u32, data string) !string {
	res := os.execute("grid-cli rmb-dl-get --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --relay ${d.relay_url} --dst ${dst} --data '${data}'")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return res.output
}

pub fn (mut d Deployer) get_node_pub_config(node_id u32) !models.PublicConfig {
	node_twin := get_node_twin(node_id, d.substrate_url)!
	res := os.execute("grid-cli rmb-node-pubConfig --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --relay ${d.relay_url} --dst ${node_twin} ")
	if res.exit_code != 0 {
		return error(res.output.trim_space())
	}

	public_config := json.decode(models.PublicConfig, res.output) or { return err }

	return public_config
}

pub fn (mut d Deployer) assign_wg_port(node_id u32) !u16 {
	node_twin := get_node_twin(node_id, d.substrate_url)!
	res := os.execute("grid-cli rmb-taken-ports --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --relay ${d.relay_url} --dst ${node_twin} ")
	if res.exit_code != 0 {
		return error(res.output)
	}

	taken_ports := json.decode([]u16, res.output) or {
		return error("can't parse node taken ports: ${err}")
	}
	port := models.rand_port(taken_ports) or { return error("can't assign wireguard port: ${err}") }

	return port
}

pub fn (mut d Deployer) rmb_deployment_deploy(dst u32, data string) !string {
	res := os.execute("grid-cli rmb-dl-deploy --substrate ${d.substrate_url} --mnemonics \"${d.mnemonics}\" --relay ${d.relay_url} --dst ${dst} --data '${data}'")
	if res.exit_code != 0 {
		return error(res.output)
	}

	return res.output
}
