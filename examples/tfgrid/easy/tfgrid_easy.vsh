#!/usr/bin/env -S v -n -w -enable-globals -cg run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.deploy
import freeflowuniverse.crystallib.ui.console

mnemonic := os.getenv('TFGRID_MNEMONIC')
ssh_key := os.getenv('SSH_KEY')

// Create the GridConfig for deployment
// Assuming "dev" is the chain network
mut grid := deploy.new_grid_client(mnemonic, .main, ssh_key)!

mut myfilter := gridproxy.nodefilter()!

myfilter.status = 'up'
myfilter.country = 'belgium'

mut gp_client := gridproxy.new(net:.main, cache:true)!
mynodes := gp_client.get_nodes(myfilter)!

console.print_debug("Found: '${mynodes.len}'nr nodes.")


if mynodes.len == 0{
	console.print_error("can't find nodes as specified in belgium")
	exit(1)
}

// Define the VM to be deployed
mut vms := deploy.GridMachinesModel{
	name: "Machinesinterface",
	node_id: 177,
	machines: [
		deploy.MachineModel{
			name: "testmachine",
			network_access: deploy.MachineNetworkAccessModel{
				public_ip4: false,
				public_ip6: false,
				planetary: true,
				mycelium: true,
			},
			capacity: deploy.ComputeCapacity{
				cpu: 5
				memory: 2048
			},
		}
	]
}

// grid.machines.deploy(vms)!
// grid.machines.list()!
// grid.machines.delete("Machinesinterface")!
grid.machines.get("Machinesinterface")!