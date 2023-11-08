module tfgrid

import json
import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import log

const pubkey = <PUBKEY>

fn test_create_and_update_deployment() {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := get_mnemonics()!
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!

	twin_id := deployer.client.get_user_twin()!

	mut network := models.Znet{
		ip_range: '10.1.0.0/16'
		subnet: '10.1.1.0/24'
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE='
		wireguard_listen_port: 3012
		peers: [
			models.Peer{
				subnet: '10.1.2.0/24'
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM='
				allowed_ips: ['10.1.2.0/24', '100.64.1.2/32']
			},
		]
	}
	mut znet_workload := models.Workload{
		version: 0
		name: 'networkaa'
		type_: models.workload_types.network
		data: json.encode_pretty(network)
		description: 'test network2'
	}

	disk_name := 'mydisk'
	zmount := models.Zmount{
		size: 2 * 1024 * 1024 * 1024
	}
	zmount_workload := zmount.to_workload(name: disk_name)

	mount := models.Mount{
		name: disk_name
		mountpoint: '/disk1'
	}

	public_ip_name := 'mypubip'
	ip := models.PublicIP{
		v4: true
	}
	ip_workload := ip.to_workload(name: public_ip_name)

	zmachine := models.Zmachine{
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		entrypoint: '/sbin/zinit init'
		network: models.ZmachineNetwork{
			public_ip: public_ip_name
			interfaces: [
				models.ZNetworkInterface{
					network: 'networkaa'
					ip: '10.1.1.3'
				},
			]
			planetary: true
		}
		compute_capacity: models.ComputeCapacity{
			cpu: 1
			memory: i64(1024) * 1024 * 1024 * 2
		}
		env: {
			'SSH_KEY': tfgrid.pubkey
		}
		mounts: [mount]
	}

	mut zmachine_workload := models.Workload{
		version: 0
		name: 'vm2'
		type_: models.workload_types.zmachine
		data: json.encode(zmachine)
		description: 'zmachine test'
	}

	zlogs := models.ZLogs{
		zmachine: 'vm2'
		output: 'wss://example_ip.com:9000'
	}
	zlogs_workload := zlogs.to_workload(name: 'myzlogswl')

	zdb := models.Zdb{
		size: 2 * 1024 * 1024
		mode: 'seq'
	}
	zdb_workload := zdb.to_workload(name: 'myzdb')

	mut deployment := models.Deployment{
		version: 0
		twin_id: twin_id
		description: 'zm kjasdf1nafvbeaf1234t21'
		workloads: [znet_workload, zmount_workload, zmachine_workload, zlogs_workload, zdb_workload,
			ip_workload]
		signature_requirement: models.SignatureRequirement{
			weight_required: 1
			requests: [
				models.SignatureRequest{
					twin_id: twin_id
					weight: 1
				},
			]
		}
	}

	deployment.add_metadata('myproject', 'hamada')
	node_id := u32(14)
	solution_provider := u64(0)

	contract_id := deployer.deploy(node_id, mut deployment, deployment.metadata, solution_provider)!
	deployer.logger.info('created contract id ${contract_id}')

	res_deployment := deployer.get_deployment(contract_id, node_id)!

	mut zmachine_ygg_ip := ''
	for wl in res_deployment.workloads {
		if wl.name == zmachine_workload.name {
			res := json.decode(models.ZmachineResult, wl.result.data)!
			zmachine_ygg_ip = res.ygg_ip
			break
		}
	}

	gw_name := models.GatewayNameProxy{
		name: 'mygwname1'
		backends: ['http://[${zmachine_ygg_ip}]:9000']
	}
	gw_name_wl := gw_name.to_workload(name: 'mygwname1')

	name_contract_id := deployer.client.create_name_contract('mygwname1')!
	deployer.logger.info('name contract id: ${name_contract_id}')

	deployment.workloads << gw_name_wl
	deployer.update_deployment(node_id, mut deployment, deployment.metadata)!
}

fn test_get_contracts() {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := get_mnemonics()!
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!
	mut grid_proxy := gridproxy.get(.dev, false)!
	contracts := grid_proxy.get_contracts(
		twin_id: model.OptionU64(u64(deployer.twin_id))
		state: 'created'
	)!
	deployer.logger.info('${contracts}')
}

fn test_cancel_deployment() {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := get_mnemonics()!
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!
	contract_ids = [u64(45684), u64(45685)]
	for cont_id in contract_ids {
		deployer.client.cancel_contract(cont_id)!
		deployer.logger.info('contract ${cont_id} is canceled')
	}
}
