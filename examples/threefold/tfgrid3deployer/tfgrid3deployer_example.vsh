#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.tfgrid3deployer
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.threefold.griddriver


fn main(){
	// mut installer:= griddriver.get()!
	// installer.install()!

	deployment_name := "mymachine"

	mut tfgrid := tfgrid3deployer.get()!
	mut deployment := tfgrid3deployer.new_deployment(deployment_name)!

	// If not sent: The client will create a network for the deployment.
	// deployment.network = NetworkSpecs{
	// 	name:     'hamadanetcafe'
	// 	ip_range: '10.10.0.0/16'
	// }

	deployment.add_machine(
		tfgrid3deployer.VMRequirements{
			name: "my_vm1",
			cpu: 1,
			memory: 2 // in GB,
			public_ip4: false,
			public_ip6: false,
			planetary: true,
			mycelium: true,
			// nodes: [u32(11)]
		},
	)

	deployment.add_machine(
		tfgrid3deployer.VMRequirements{
			name: "my_vm2",
			cpu: 1,
			memory: 2 // in GB,
			public_ip4: false,
			public_ip6: false,
			planetary: true,
			mycelium: true,
			// nodes: [u32(28)]
		}
	)

	deployment.add_zdb(
		tfgrid3deployer.ZDBRequirements{
			name: "my_zdb"
			password: "my_passw&rd"
			size: 2 // in GB
			description: ""
			// node_id: u32(28)
		}
	)

	deployment.deploy()!

	// TODO::
	// deployment.vms.get("my_vm1")
	// deployment.zdbs.get("my_zdb")
	// deployment.delete()!
	// println(deployment.vms)
	// deployment.vm_get("my_vm")!
	// println(vm_result)
}
