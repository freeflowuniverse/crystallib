module main

import freeflowuniverse.crystallib.threefold.higher_grid.models
import os

fn do()! {
	mnemonic := os.getenv('TFGRID_MNEMONIC')
	ssh_key := os.getenv('SSH_KEY')

	// Create the GridConfig for deployment
	// Assuming "dev" is the chain network
	mut grid := models.new_grid_client(mnemonic, .dev, ssh_key)!

	// Define the VM to be deployed
	mut vms := models.GridMachinesModel{
		name: "Machinesinterface",
		node_id: 177
		network: models.NetworkModel{
			name: "Netselo",
			ip_range: '10.249.0.0/16',
			subnet: '10.249.0.0/24',
		},
		machines: [
			models.MachineModel{
				name: "testmachine",
				network_access: models.MachineNetworkAccessModel{
					public_ip4: false,
					public_ip6: false,
					planetary: true,
					mycelium: true,
				},
				capacity: models.ComputeCapacity{
					cpu: 5
					memory: 2048
				},
			}
		]
	}

	// grid.machines.deploy(vms)!
	grid.machines.list()!
}

fn main() {
	do()!
}
