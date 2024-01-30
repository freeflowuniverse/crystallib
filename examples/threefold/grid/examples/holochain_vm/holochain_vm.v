module main

import json
import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log
import os

fn main() {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := os.getenv('MNEMONICS')
	
	chain_network := tfgrid.ChainNetwork.dev // User your desired network
	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!
	
	node_id := u32(27) // get from user or use gridproxy to get nodeid
	network_name := 'network1' // autocreate a network
	wg_port := deployer.assign_wg_port(node_id)!
	mut network := models.Znet{
		ip_range: '10.1.0.0/16' // auto-assign
		subnet: '10.1.1.0/24' // auto-assign
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=' // autocreate
		wireguard_listen_port: wg_port
		peers: [
			models.Peer{
				subnet: '10.1.2.0/24' // auto-assign
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM=' // get from autocreated private key
				allowed_ips: ['10.1.2.0/24', '100.64.1.2/32'] // auto-assign
			},
		]
	}
	mut znet_workload := network.to_workload(name: network_name, description: 'test_network1')

	ssh_key := os.getenv('SSH_KEY')
	mut code_server_pass := os.getenv('CODE_SERVER_PASSWORD')
	if ssh_key.len == 0{
		panic('SSH_KEY env var must be set')
	}

	if code_server_pass.len == 0{
		code_server_pass = 'password'
	}

	zmachine := models.Zmachine{
		flist: 'https://hub.grid.tf/mariobassem1.3bot/threefolddev-holochain-latest.flist' // from user or default to ubuntu
		network: models.ZmachineNetwork{
			public_ip: ''
			interfaces: [
				models.ZNetworkInterface{
					network: network_name
					ip: '10.1.1.3'
				},
			]
			planetary: true
		}
		entrypoint: '/usr/local/bin/entrypoint.sh' // from user or default
		compute_capacity: models.ComputeCapacity{
			cpu: 4
			memory: i64(8) * 1024 * 1024 * 1024
		}
		size: u64(30) * 1024 * 1024 * 1024
		env: {
			'SSH_KEY': ssh_key,
			'CODE_SERVER_PASSWORD': code_server_pass
		}
	}
	mut zmachine_workload := zmachine.to_workload(name: 'vm2', description: 'zmachine_test')

	signature_requirement := models.SignatureRequirement{
		weight_required: 1
		requests: [
			models.SignatureRequest{
				twin_id: deployer.twin_id
				weight: 1
			},
		]
	}

	mut deployment := models.new_deployment(
		twin_id: deployer.twin_id
		description: 'test deployment'
		workloads: [znet_workload, zmachine_workload]
		signature_requirement: signature_requirement
	)
	deployment.add_metadata('vm', 'SimpleVM')

	contract_id := deployer.deploy(node_id, mut deployment, deployment.metadata, 0) or {
		logger.error('failed to deploy deployment: ${err}')
		exit(1)
	}
	logger.info('deployment contract id: ${contract_id}')
	dl := deployer.get_deployment(contract_id, node_id) or {
		logger.error('failed to get deployment data: ${err}')
		exit(1)
	}

	machine_res := get_machine_result(dl)!
	logger.info('zmachine result: ${machine_res}')
}

fn get_machine_result(dl models.Deployment) !models.ZmachineResult {
	for _, w in dl.workloads {
		if w.type_ == models.workload_types.zmachine {
			res := json.decode(models.ZmachineResult, w.result.data)!
			return res
		}
	}

	return error('failed to get zmachine workload')
}
