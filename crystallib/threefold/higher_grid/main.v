module main

import freeflowuniverse.crystallib.threefold.higher_grid.models
import os

fn do()! {
	mnemonic := os.getenv('TFGRID_MNEMONIC')
	if mnemonic.len == 0 {
		panic("Before running the script, export the `TFGRID_MNEMONIC` and point it to your wallet secret.")
	}

	ssh_key := os.getenv('SSH_KEY')
	if ssh_key.len == 0 {
		panic("SSH key is missing. Please export the `SSH_KEY` environment variable.")
	}

	// Create the GridConfig for deployment
	grid_config := models.GridConfig{
		mnemonic: mnemonic
		chain_network: .dev // Assuming "dev" is the chain network
		node_id: 177
	}

	// Define the VM to be deployed
	mut vms := models.GridVM{
		name: "Machinesinterface",
		network: models.NetworkModel{
			name: "Netselo",
			ip_range: '10.249.0.0/16',
			subnet: '10.249.0.0/24',
		},
		machines: [
			models.MachineModel{
				name: "test machine",
				deployment_name: "test_deployment",
				network_access: models.MachineNetworkAccessModel{
					public_ip: true,
					public_ip6: false,
					planetary: true,
					mycelium: true,
				},
				capacity: models.ComputeCapacity{
					cpu: 1
					memory: 1024
				},
				pub_sshkeys: [ssh_key],
			}
		]
	}

	// Deploy the VM
	vms.deploy(grid_config)!
}

fn main() {
	do()!
}
