module main

import json
import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log
import os
import flag
import freeflowuniverse.crystallib.threefold.gridproxy
import rand

const gb = int(1024) * 1024 * 1024

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('Holochain dev tool')
	fp.version('v0.0.1')
	fp.skip_executable()

	mnemonics := fp.string_opt('mnemonic', `m`, 'Your Mnemonic phrase')!
	chain_network := fp.string('network', `n`, 'main', 'Your desired chain network (main, test, qa, dev). Defaults to main')
	ssh_key := fp.string_opt('ssh_key', `s`, 'Your public ssh key')!
	code_server_pass := fp.string('code_server_pass', `p`, 'password', 'Machine code server password. This will be set as a password for the code server on the deployed machine. Defaults to password')
	cpu := fp.int('cpu', `c`, 4, 'Machine CPU provisioning. Defaults to 4')
	memory := fp.int('ram', `r`, 8, 'Machine memory provisioning in GB. Defaults to 8')
	disk := fp.int('disk', `d`, 30, 'Machine Disk space provisioning in GB. Defaults to 30')

	mut logger := log.Log{
		level: .debug
	}

	chain_net_enum := get_chain_network(chain_network)!
	mut deployer := tfgrid.new_deployer(mnemonics, chain_net_enum, mut logger)!

	// TODO: wrap in a function
	gp_net := match chain_net_enum {
		.dev { gridproxy.TFGridNet.dev }
		.qa { gridproxy.TFGridNet.qa }
		.test { gridproxy.TFGridNet.test }
		.main { gridproxy.TFGridNet.main }
	}

	mut gridproxy_client := gridproxy.get(gp_net, false)!
	mut node_it := gridproxy_client.get_nodes_has_resources(
		free_mru_gb: u64(memory)
		free_sru_gb: u64(disk)
		free_cpu: u64(cpu)
	)
	nodes := node_it.next()
	mut node_id := u32(0) // get from user or use gridproxy to get nodeid
	if nodes_list := nodes {
		node_id = u32(nodes_list[0].node_id)
	} else {
		panic('cannot find a suitable node matching your specs')
	}

	network_name := 'net_${rand.string(5).to_lower()}' // autocreate a network
	wg_port := deployer.assign_wg_port(node_id)!
	mut network := models.Znet{
		ip_range: '10.1.0.0/16' // auto-assign
		subnet: '10.1.1.0/24' // auto-assign
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=' // autocreate
		wireguard_listen_port: wg_port
		// peers: [
		// 	models.Peer{
		// 		subnet: '10.1.2.0/24' // auto-assign
		// 		wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM=' // get from autocreated private key
		// 		allowed_ips: ['10.1.2.0/24', '100.64.1.2/32'] // auto-assign
		// 	},
		// ]
	}

	mut znet_workload := network.to_workload(name: network_name, description: 'test_network1')

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
			cpu: u8(cpu)
			memory: i64(memory) * 1024 * 1024 * 1024
		}
		size: u64(disk) * 1024 * 1024 * 1024
		env: {
			'SSH_KEY':              ssh_key
			'CODE_SERVER_PASSWORD': code_server_pass
		}
	}
	mut zmachine_workload := zmachine.to_workload(
		name: 'vm_${rand.string(5).to_lower()}'
		description: 'zmachine_test'
	)

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
		description: 'holochain deployment'
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

fn get_chain_network(network string) !tfgrid.ChainNetwork {
	chain_net_enum := match network {
		'dev' { tfgrid.ChainNetwork.dev }
		'qa' { tfgrid.ChainNetwork.qa }
		'test' { tfgrid.ChainNetwork.test }
		'main' { tfgrid.ChainNetwork.main }
		else { return error('invalid chain newtork ${network}. must be one of (dev, qa, test, main)') }
	}

	return chain_net_enum
}

/*
	gridproxy call to assign node - done
	generate private key for wireguard
	add option to add public ip
*/
