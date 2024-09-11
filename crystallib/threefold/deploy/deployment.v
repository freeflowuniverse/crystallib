module deploy

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import rand


@[heap]
pub struct TFDeployment {
pub mut:
    name     string = 'default'
    description string
    vms []VMachine
    // zdbs  //TODO
    // webgw     
mut:
    deployer	  ?grid.Deployer
}

fn (mut self TFDeployment) new_deployer() !grid.Deployer {
    if self.deployer == none {
        mut grid_client := get()!
        network := match grid_client.network {
            .dev { grid.ChainNetwork.dev }
            .test { grid.ChainNetwork.test }
            .main { grid.ChainNetwork.main }
        }
        self.deployer = grid.new_deployer(grid_client.mnemonic, network)!
    }

    return self.deployer or { return error('Deployer not initialized') }
}


pub fn (mut self TFDeployment) vm_deploy(args_ VMRequirements)!VMachine {
    console.print_header('Starting deployment process.')
    console.print_header('Creating workloads.')
    
    mut deployer := self.new_deployer() or {
        return error('Deployer is not initialized')
    }

    mut workloads := []grid_models.Workload{}
    mut public_ip_name := ''
    node_id := u32(11)

    if args_.network != none {
        mut network := args_.network or {
            return error('Network is not initialized')
        }

        wg_port := deployer.assign_wg_port(node_id)!
        workloads << create_network_workload(network, wg_port)!
    }

    if args_.public_ip4 || args_.public_ip6 {
        public_ip_name = rand.string(5).to_lower()
        workloads << create_public_ip_workload(
            args_.public_ip4,
            args_.public_ip6,
            public_ip_name
        )
    }

    // Handle potential error from create_zmachine_workload()
    zmachine := create_zmachine_workload(
        args_,
        public_ip_name
    )!

    // Handle potential error from to_workload()
    workloads << zmachine.to_workload(
        name: args_.name,
        description: args_.description
    )

    console.print_header('Creating deployment.')
    mut deployment := grid_models.new_deployment(
		twin_id: deployer.twin_id,
		description: 'VGridClient Deployment',
		workloads: workloads,
		signature_requirement: create_signature_requirement(deployer.twin_id),
	)

	console.print_header('Setting metadata.')
	deployment.add_metadata("vm", args_.name)
    console.print_header('Deploying workloads...')

	contract_id := deployer.deploy(
        node_id,
        mut deployment,
        deployment.metadata,
        0
    ) or {
		return error('Deployment failed: ${err}')
	}

	console.print_header('Deployment successful. Contract ID: ${contract_id}')
    return VMachine{
        tfchain_contract_id: contract_id
        name: args_.name
        description: args_.description
    }
}


// Helper function to create signature requirements
fn create_signature_requirement(twin_id int) grid_models.SignatureRequirement {
	console.print_header('Setting signature requirement.')
	return grid_models.SignatureRequirement{
		weight_required: 1,
		requests: [
			grid_models.SignatureRequest{
				twin_id: u32(twin_id),
				weight: 1,
			},
		],
	}
}

fn create_network_workload(network NetworkSpecs, wg_port u32) !grid_models.Workload {
	console.print_header('Creating network workload.')
	return grid_models.Znet{
		ip_range: network.ip_range,
		subnet: network.subnet,
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=',
		wireguard_listen_port: u16(wg_port),
		mycelium: grid_models.Mycelium{
			hex_key: rand.string(32).bytes().hex(),
		},
		peers: [
			grid_models.Peer{
				subnet: network.subnet,
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM=',
				allowed_ips: [network.subnet],
			},
		]
	}.to_workload(
		name: network.name,
		description: 'VGridClient Network',
	)
}

// Helper function to create a public IP workload
fn create_public_ip_workload(is_v4 bool, is_v6 bool, name string) grid_models.Workload {
	console.print_header('Creating Public IP workload.')
	return grid_models.PublicIP{
		v4: is_v4,
		v6: is_v6,
	}.to_workload(name: name)
}

// Helper function to create a Zmachine workload
fn create_zmachine_workload(args_ VMRequirements, public_ip_name string)! grid_models.Zmachine {
    console.print_header('Creating Zmachine workload.')
    mut grid_client := get()!
    mut network := args_.network or {
        return error('Network is not initialized')
    }
    
    return grid_models.Zmachine{
        flist: 'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist',
        network: grid_models.ZmachineNetwork{
            interfaces: [
                grid_models.ZNetworkInterface{
                    network: network.name,
                    ip: network.ip_range.split('/')[0],
                },
            ],
            public_ip: public_ip_name,
            planetary: args_.planetary,
            mycelium: grid_models.MyceliumIP{
                network: network.name,
                hex_seed: rand.string(6).bytes().hex(),
            }
        },
        entrypoint: '/sbin/zinit init',
        compute_capacity: grid_models.ComputeCapacity{
            cpu: u8(args_.cpu),
            memory: i64(args_.memory) * 1024 * 1024,
        },
        env: {
            'SSH_KEY': grid_client.ssh_key,
        }
    }
}

//gets the info from the TFGrid
fn (mut self TFDeployment) load()!{
    //TODO: load the metadata from TFGrid and populate the TFDeployment ((ssh_key))
    mut grid_client := get()!
}

// fn (mut self TFDeployment) save()! {
//     //TODO: save info to the TFChain, encrypt with mnemonic (griddriver should do this)
// }

// pub fn (mut self TFDeployment) vm_get(name string)!VMachine {
//     //TODO: check vm already exists if not fail
//     //TODO: load the metadata from the VM, populater a VMachine

//     //the name on TFChain is $deploymentname__$name

// }

// pub fn (mut self TFDeployment) vm_delete(name string)!VMachine {
//     //TODO: check vm already exists if not fail
//     //TODO: load the metadata from the VM, populater a VMachine

//     //the name on TFChain is $deploymentname__$name

// }


// pub fn (mut self TFDeployment) vm_list()![]string {
//     //list names of vm's we have for this deployment
// }



// fn (self TFDeployment) encode() ![]u8 {
// 	mut b := encoder.new()
//     //encode what is required on TFDeployment level
//     b.add_string(self.name)
// 	for vm in self.vms{
//         data:=vm.encode()!
//         b.add_int(v.data.len)
//         b.add_bytes(data)        
//     }
// }

