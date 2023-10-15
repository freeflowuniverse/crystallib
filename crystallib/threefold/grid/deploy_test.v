module tfgrid

import json
import freeflowuniverse.crystallib.threefold.grid.models
import log


fn test_deploy_deployment() {
	mnemonics := ''
	mut logger := log.Log{
		level: .debug
	}
	mut deployer := new_deployer(mnemonics, .dev, mut logger)!
	
	node_id := u32(14)
	twin_id := u32(49)
	node_twin_id := u32(22)

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

	zmachine := models.Zmachine{
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		network: models.ZmachineNetwork{
			public_ip: ''
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
			'SSH_KEY': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU= mario@mario-machine'
		}
	}

	mut zmachine_workload := models.Workload{
		version: 0
		name: 'vm2'
		type_: models.workload_types.zmachine
		data: json.encode(zmachine)
		description: 'zmachine test'
	}

	mut deployment := models.Deployment{
		version: 0
		twin_id: twin_id
		metadata: 'zm dep'
		description: 'zm kjasdf1nafvbeaf1234t21'
		workloads: [znet_workload, zmachine_workload]
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

	hash := deployment.challenge_hash()
	hex_hash := hash.hex()

	contract_id := deployer.client.create_node_contract(0, '', hex_hash, 0, 0)!
	deployment.contract_id = contract_id

	signature := deployer.client.sign_deployment(hex_hash)!
	deployment.add_signature(twin_id, signature)

	payload := deployment.json_encode()
	print('payload: ${payload}')
	exit(0)
	mut res := deployer.client.rmb_call(node_twin_id, "zos.deployment.deploy", payload) or {
		print('error: ${err}')
		exit(1)
	}
	// mut mb := client.MessageBusClient
	// {
	// 	client:
	// 	redisclient.connect('localhost:6379') or { panic(err) }
	// }
	// mut msg := client.prepare('zos.deployment.deploy', [2], 0, 2)
	// mb.send(msg, payload)
	// response := mb.read(msg)
	// println('Result Received for reply: ${msg.retqueue}')
	// for result in response {
	// 	println(result)
	// 	println(result.data)
	// }
}
