module main

import freeflowuniverse.crystallib.threefold.deploy

fn main(){
	mut grid_client := deploy.TFGridClient{
		mnemonic: "xxx"
		ssh_key: "xxx"
		network: .dev
	}

	vm := deploy.VMRequirements{
		name: "mymachine",
		cpu: 1,
		memory: 2,
		public_ip4: false,
		public_ip6: false,
		planetary: true,
		mycelium: true
	}

	mut deployment := deploy.TFDeployment{}
	vm_result := deployment.vm_deploy(vm)!
	println(vm_result)
}
