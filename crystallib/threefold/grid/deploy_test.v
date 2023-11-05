module grid

import json
import freeflowuniverse.crystallib.threefold.grid.models
import log

fn test_create_and_update_deployment() {
	mnemonics := ''
	mut logger := log.Log{
		level: .debug
	}
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!

	twin_id := deployer.client.get_user_twin()!

	mut network := models.Znet{
		ip_range: '10.1.0.0/16'
		subnet: '10.1.1.0/24'
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE='
		wireguard_listen_port: 3011
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
		name: 'network'
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
					network: 'network'
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
			'SSH_KEY': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3OCaZ3mHWVqu5pvi14XDYR+F7A4SEVWMDFyBPjtUfTORuxLSR4/29TzT3Dbc60sY8/Lr5OjR27Ubouh8f5xDc6P89UoyTDLe0HWYnnsYRGt1zHbhU0wYOypQsgWObEAKOo78/20JgcDkx7Aga59w6QAS+OUfZ4HrSfyeG7NedN9H0YiLuKVA1rtvpzF/SZiPt3zTIP3qLVJoW5QphTB4m5cHR5+mmYIAco8U/C/H83IYv98Powi9OLxeGOi/WMTjNcA2EdNcIGO13krSKU+xx8vm7wPPNKaex1Ps9bP6DTDALgf/El2Y33MJWA4V9vKlm1kV1N58c5kurUURPdVVN8B1pRKKP8esQIyOx3hQu5RQ3cBm7kYiUQLnjQIRpIPtTYtqugCJuPG57nMzNL4KZdSmjK++KDSNtUAR78QnjvRJgRKtO7GJdusdeHudGEvP/DgjjRdIunf8hHoB6AYbC5D2ToCTWrHcjU9WKAdzSHbzqSlC3G6k026tcnrx+LFE= plumber@mario'
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
		name: 'mygwname'
		backends: ['http://[${zmachine_ygg_ip}]:9000']
	}
	gw_name_wl := gw_name.to_workload(name: 'mygwname')

	name_contract_id := deployer.client.create_name_contract('mygwname')!
	deployer.logger.info('name contract id: ${name_contract_id}')

	deployment.workloads << gw_name_wl
	deployer.update_deployment(node_id, mut deployment, deployment.metadata)!
}

fn test_cancel_deployment() {
	mnemonics := ''
	mut logger := log.Log{
		level: .debug
	}
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!

	contract_id := u64(43885)
	deployer.client.cancel_contract(contract_id)!

	deployer.logger.info('contract ${contract_id} is canceled')
}
