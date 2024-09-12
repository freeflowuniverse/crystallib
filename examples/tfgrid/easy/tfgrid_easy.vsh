#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.deploy
import freeflowuniverse.crystallib.ui.console


fn main(){
	mut vm := deploy.VMRequirements{
		name: "mymachine",
		cpu: 1,
		memory: 2,
		public_ip4: false,
		public_ip6: false,
		planetary: true,
		mycelium: true,
		// nodes: [11]
	}

	mut deployment := deploy.TFDeployment{}
	// vm_result := deployment.vm_deploy(vm)!
	vm_result := deployment.vm_get("mymachine")!
	println(vm_result)
}
