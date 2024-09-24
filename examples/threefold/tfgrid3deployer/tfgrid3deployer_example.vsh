#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.tfgrid3deployer
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.threefold.griddriver


fn main(){
	// mut installer:= griddriver.get()!
	// installer.install()!

	tfgrid3deployer.get()!
	deployment_name := "my_deployment2"

	// mut deployment := tfgrid3deployer.new_deployment(deployment_name)!
	mut deployment := tfgrid3deployer.get_deployment(deployment_name)!

	// If not sent: The client will create a network for the deployment.
	// deployment.network = NetworkSpecs{
	// 	name:     'hamadanetcafe'
	// 	ip_range: '10.10.0.0/16'
	// }

	deployment.add_machine(name: "my_vm1" cpu: 1 memory: 2 planetary: true mycelium: true  nodes: [u32(11)])
	// deployment.add_zdb(name: "my_zdb", password: "my_passw&rd", size: 2)
	// deployment.add_webname(name: 'mywebname2', backend: 'http://37.27.132.47:8000')
	// deployment.add_machine(name: "my_vm1" cpu: 1 memory: 2 planetary: true mycelium: true  nodes: [u32(28)])
	// deployment.deploy()!

	vm1 := deployment.vm_get("my_vm1")!
	reachable := vm1.healthcheck()!
	println("vm reachable: ${reachable}")
	
	// if !reachable {
	// 	deployment.vm_delete()!
	// 	deployment.vm_deploy()!
	// }

	// if !rach {
	// 	vm1.delete()!
	// 	vm1.deploy()!
	// }

	// TODO::
	// deployment.zdbs.get("my_zdb")
	// deployment.delete()!
	// println(deployment.vms)
	// deployment.vm_get("my_vm")!
	// println(vm_result)
}
