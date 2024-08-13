module grid

import json
import log
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.threefold.grid.models

struct VMSpecs{
	deployment_name string
	name string
	nodeid string
	pub_sshkeys []string
	flist string //if any, if used then ostype not used
	ostype OSType
}

enum OSType{
	ubuntu_22_04
	ubuntu_24_04
	arch
	alpine
}

struct VMDeployed{
	name string
	nodeid string
	//size ..
	guid  string
	yggdrasil_ip string
	mycelium_ip string	

}

pub fn (vm VMDeployed) builder_node() !&builder.Node {
	mut factory := builder.new()!
	return factory.node_new(
		ipaddr: vm.mycelium_ip
	)!
}

//only connect to yggdrasil and mycelium
fn (deployer Deployer) vm_deploy(args_ VMSpecs) !VMDeployed {
	mut args := args_
	// deploymentstate_db.set(args.deployment_name,"vm_${args.name}",json.encode(VMDeployed))!
	
	mnemonics := grid.get_mnemonics()!
	chain_network := grid.ChainNetwork.dev // User your desired network

	mut logger := &log.Log{}
	logger.set_level(.debug)

	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!

	vm := models.VM{
		name: 'vm1'
		env_vars: {
			'SSH_KEY': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTwULSsUubOq3VPWL6cdrDvexDmjfznGydFPyaNcn7gAL9lRxwFbCDPMj7MbhNSpxxHV2+/iJPQOTVJu4oc1N7bPP3gBCnF51rPrhTpGCt5pBbTzeyNweanhedkKDsCO2mIEh/92Od5Hg512dX4j7Zw6ipRWYSaepapfyoRnNSriW/s3DH/uewezVtL5EuypMdfNngV/u2KZYWoeiwhrY/yEUykQVUwDysW/xUJNP5o+KSTAvNSJatr3FbuCFuCjBSvageOLHePTeUwu6qjqe+Xs4piF1ByO/6cOJ8bt5Vcx0bAtI8/MPApplUU/JWevsPNApvnA/ntffI+u8DCwgP'
		}
	}

	res := deployer.client.deploy_single_vm(node_id, args.deployment_name, vm, deployer.env)!
	deployer.logger.info('${res}')

	vm_deployed := grid.VMDeployed{
		name: args.name
		
	}

	return vm_deployed
}