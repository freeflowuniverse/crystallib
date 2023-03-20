module main

import freeflowuniverse.crystallib.routeros



fn main(){
	// TODO: a connection should be added during initialization of routeros where we can connect to ssh and execute command
	mut ros := routeros.RouterOS{}
	ros.load_addresses()
	ros.load_vlans()
	ros.print_config()

	mut configurator := routeros.Configurator{ros: ros}
	vlan := routeros.Vlan{name: "vlan4", ifc: "ether4", id: 4}
	configurator.add_vlan(vlan)!
	
	// this will print the config including the new added vlan
	configurator.ros.print_config()
	
	// this will only print the config to be applied for now
	// TODO: use ssh to execute those commands
	configurator.configure()

	//this will fail because we already have this vlan configured
	configurator.add_vlan(vlan)!
}
