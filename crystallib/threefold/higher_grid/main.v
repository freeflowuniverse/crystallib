module main
import freeflowuniverse.crystallib.threefold.higher_grid.models
import freeflowuniverse.crystallib.threefold.grid.models


fn do()!{
	mut grid := new_gridclient(mnemonic: "", network: "") or {}

	mut vms := models.GridVM{
		name: "Machines interface",
		network: models.NetworkModel{
			name: "Netselo",
			ip_range: "10.249.0.0/16",
		},
		machines: [
			models.MachineModel{
				name: "test machine",
				deployment_name: "test deployment",
				network_access: models.MachineNetworkAccessModel{
					public_ip: false,
					public_ip6: false,
					planetary: true,
					mycelium: true,
				},
				capacity: models.ComputeCapacity{
					cpu: 1
					memory: 1024
				},
				pub_sshkeys: [""],
				nodeid: 5
			}
		]
	}

	grid.vms.deploy(vms)
}

fn main(){
	do()
}