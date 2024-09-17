#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.tfgrid3deployer
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.threefold.griddriver


fn main(){
	// mut installer:= griddriver.get()!
	// installer.install()!

	mut tfgrid := tfgrid3deployer.get()!
	deployment_name := "mymachine"

	mut vm1 := tfgrid3deployer.VMRequirements{
		name: "my_vm",
		cpu: 1,
		memory: 2,
		public_ip4: false,
		public_ip6: false,
		planetary: true,
		mycelium: true,
		nodes: [11]
	}

	mut vm2 := tfgrid3deployer.VMRequirements{
		name: "my_vm2",
		cpu: 1,
		memory: 2,
		public_ip4: false,
		public_ip6: false,
		planetary: true,
		mycelium: true,
		// nodes: [11]
	}

	mut deployment := tfgrid3deployer.new_deployment(deployment_name)!
	deployment.vms_deploy([vm1, vm2])!
	println(deployment.vms)
	// deployment.vm_get("my_vm")!
	// println(vm_result)
}
