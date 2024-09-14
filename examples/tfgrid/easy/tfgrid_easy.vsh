#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.deploy
import freeflowuniverse.crystallib.ui.console


fn main(){
	deployment_name := "mymachine"
	mut vm := deploy.VMRequirements{
		name: deployment_name,
		cpu: 1,
		memory: 2,
		public_ip4: false,
		public_ip6: false,
		planetary: true,
		mycelium: true,
		// nodes: [11]
	}

	mut deployment := deploy.TFDeployment{}
	deployment.vm_deploy(vm)!
	vm_result := deployment.vm_get(deployment_name)!
	println(vm_result)
}
