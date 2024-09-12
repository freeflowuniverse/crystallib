#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.deploy
import freeflowuniverse.crystallib.ui.console


fn main(){
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
