#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.tfgrid3deployer
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.threefold.griddriver


fn main(){



	// mut installer:= griddriver.get()!
	// installer.install()!

	mut tfgrid := tfgrid3deployer.get()!

	// deployment_name := "mymachine"
	// mut vm := deploy.VMRequirements{
	// 	name: deployment_name,
	// 	cpu: 1,
	// 	memory: 2,
	// 	public_ip4: false,
	// 	public_ip6: false,
	// 	planetary: true,
	// 	mycelium: true,
	// 	// nodes: [11]
	// }

	// mut deployment := deploy.TFDeployment{}
	// deployment.vm_deploy(vm)!
	// vm_result := deployment.vm_get(deployment_name)!
	// println(vm_result)
}
