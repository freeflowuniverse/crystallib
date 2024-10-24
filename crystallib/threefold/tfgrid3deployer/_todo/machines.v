module models

import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import rand
import freeflowuniverse.crystallib.ui.console
import json

// Deploy the workloads
pub fn (mut gm GridMachinesModel) deploy(vms GridMachinesModel) ! {
	console.print_header('Starting deployment process.')

	// Prepare Workloads
	workloads := create_workloads(mut gm, vms)!

	// Create and deploy deployment
	contract_id := create_and_deploy_deployment(mut gm, vms, workloads)!

	// Fetch deployment result
	machine_res := fetch_deployment_result(mut gm.client.deployer, contract_id, u32(vms.node_id))!
	console.print_header('Zmachine result: ${machine_res}')
}

// Helper function to create workloads
fn create_workloads(mut gm GridMachinesModel, vms GridMachinesModel) ![]Workload {
	console.print_header('Creating workloads.')

	mut workloads := []grid_models.Workload{}

	// Create network workload
	wg_port := gm.client.deployer.assign_wg_port(u32(vms.node_id))!
	workloads << create_network_workload(vms, wg_port)

	// Create machine workloads
	mut public_ip_name := ''
	for machine in vms.machines {
		if machine.network_access.public_ip4 || machine.network_access.public_ip6 {
			public_ip_name = rand.string(5).to_lower()
			workloads << create_public_ip_workload(machine.network_access.public_ip4,
				machine.network_access.public_ip6, public_ip_name)
		}
		workloads << create_zmachine_workload(machine, vms.network, gm.ssh_key, public_ip_name).to_workload(
			name:        machine.name
			description: 'VGridClient Zmachine'
		)
	}

	return workloads
}

// Helper function to create and deploy deployment
fn create_and_deploy_deployment(mut gm GridMachinesModel, vms GridMachinesModel, workloads []Workload) !int {
	console.print_header('Creating deployment.')

	mut deployment := grid_models.new_deployment(
		twin_id:               gm.client.deployer.twin_id
		description:           'VGridClient Deployment'
		workloads:             workloads
		signature_requirement: create_signature_requirement(gm.client.deployer.twin_id)
	)

	log_and_set_metadata(mut logger, mut deployment, 'vm', vms.name)

	console.print_header('Deploying workloads...')
	contract_id := gm.client.deployer.deploy(u32(vms.node_id), mut deployment, deployment.metadata,
		0) or {
		logger.error('Deployment failed: ${err}')
		return err
	}

	console.print_header('Deployment successful. Contract ID: ${contract_id}')
	return int(contract_id)
}

// Helper function to fetch deployment result
fn fetch_deployment_result(mut deployer grid.Deployer, contract_id int, node_id u32) !ZmachineResult {
	dl := deployer.get_deployment(u64(contract_id), node_id) or {
		logger.error('Failed to get deployment data: ${err}')
		exit(1)
	}

	return get_machine_result(dl)!
}

// Helper function to create a Zmachine workload
fn create_zmachine_workload(machine MachineModel, network NetworkInfo, ssh_key string, public_ip_name string) Zmachine {
	console.print_header('Creating Zmachine workload.')
	return grid_models.Zmachine{
		flist:            'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist'
		network:          grid_models.ZmachineNetwork{
			interfaces: [
				grid_models.ZNetworkInterface{
					network: network.name
					ip:      network.ip_range.split('/')[0]
				},
			]
			public_ip:  public_ip_name
			planetary:  machine.network_access.planetary
			mycelium:   grid_models.MyceliumIP{
				network:  network.name
				hex_seed: rand.string(6).bytes().hex()
			}
		}
		entrypoint:       '/sbin/zinit init'
		compute_capacity: grid_models.ComputeCapacity{
			cpu:    u8(machine.capacity.cpu)
			memory: i64(machine.capacity.memory) * 1024 * 1024
		}
		env:              {
			'SSH_KEY': ssh_key
		}
	}
}

// Helper function to create a network workload
fn create_network_workload(gm GridMachinesModel, wg_port u32) Workload {
	console.print_header('Creating network workload.')
	return grid_models.Znet{
		ip_range:              gm.network.ip_range
		subnet:                gm.network.subnet
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE='
		wireguard_listen_port: u16(wg_port)
		mycelium:              grid_models.Mycelium{
			hex_key: rand.string(32).bytes().hex()
		}
		peers:                 [
			grid_models.Peer{
				subnet:               gm.network.subnet
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM='
				allowed_ips:          [gm.network.subnet]
			},
		]
	}.to_workload(
		name:        gm.network.name
		description: 'VGridClient Network'
	)
}

// Helper function to create a public IP workload
fn create_public_ip_workload(is_v4 bool, is_v6 bool, name string) Workload {
	console.print_header('Creating Public IP workload.')
	return grid_models.PublicIP{
		v4: is_v4
		v6: is_v6
	}.to_workload(name: name)
}

// Helper function to create signature requirements
fn create_signature_requirement(twin_id int) SignatureRequirement {
	console.print_header('Setting signature requirement.')
	return grid_models.SignatureRequirement{
		weight_required: 1
		requests:        [
			grid_models.SignatureRequest{
				twin_id: u32(twin_id)
				weight:  1
			},
		]
	}
}

// Helper function to log and set metadata
fn log_and_set_metadata(mut logger log.Log, mut deployment Deployment, key string, value string) {
	console.print_header('Setting ${key} metadata.')
	deployment.add_metadata(key, value)
}

// Helper function to get the deployment result
fn get_machine_result(dl Deployment) !ZmachineResult {
	for _, w in dl.workloads {
		if w.type_ == grid_models.workload_types.zmachine {
			res := json.decode(grid_models.ZmachineResult, w.result.data)!
			return res
		}
	}
	return error('Failed to get Zmachine workload')
}

pub fn (mut gm GridMachinesModel) list() ![]Deployment {
	mut deployments := []grid_models.Deployment{}
	console.print_header('Listing active contracts.')
	contracts := gm.client.contracts.get_my_active_contracts() or {
		return error('Cannot list twin contracts due to: ${err}')
	}

	console.print_header('Active contracts listed.')
	console.print_header('Listing deployments.')

	for contract in contracts {
		console.print_header('Listing deployment node ${contract.details.node_id}.')
		if contract.contract_type == 'node' {
			dl := gm.client.deployer.get_deployment(contract.contract_id, u32(contract.details.node_id)) or {
				console.print_stderror('Cannot list twin deployment for contract ${contract.contract_id} due to: ${err}.')
				continue
			}
			deployments << dl
			console.print_header('Deployment Result: ${dl}.')
		}
	}
	return deployments
}

fn (mut gm GridMachinesModel) list_contract_names() ![]string {
	contracts := gm.client.contracts.get_my_active_contracts()!
	mut names := []string{}
	for contract in contracts {
		res := json.decode(ContractMetaData, contract.details.deployment_data) or {
			return error('Cannot decode the deployment metadata due to: ${err}')
		}
		names << res.name
	}
	return names
}

pub fn (mut gm GridMachinesModel) delete(deployment_name string) ! {
	console.print_header('Deleting deployment with name: ${deployment_name}.')
	console.print_header('Listing the twin `${gm.client.deployer.twin_id}` active contracts.')
	contracts := gm.client.contracts.get_my_active_contracts() or {
		return error('Cannot list twin contracts due to: ${err}')
	}

	console.print_header('Active contracts listed.')

	for contract in contracts {
		res := json.decode(ContractMetaData, contract.details.deployment_data) or {
			return error('Cannot decode the contract deployment data due to: ${err}')
		}

		if res.name == deployment_name {
			console.print_header('Start deleting deployment ${deployment_name}.')
			gm.client.deployer.client.cancel_contract(contract.contract_id) or {
				return error('Cannot delete deployment due to: ${err}')
			}
			console.print_header('Deployment ${deployment_name} deleted!.')
		}
	}
}

// Placeholder for get operation
pub fn (mut gm GridMachinesModel) get(deployment_name string) ![]Deployment {
	mut deployments := []grid_models.Deployment{}
	contracts := gm.client.contracts.get_my_active_contracts() or {
		return error('Cannot list twin contracts due to: ${err}')
	}

	for contract in contracts {
		if contract.contract_type == 'node' {
			dl := gm.client.deployer.get_deployment(contract.contract_id, u32(contract.details.node_id)) or {
				console.print_stderror('Cannot list twin deployment for contract ${contract.contract_id} due to: ${err}.')
				continue
			}
			if dl.metadata.len != 0 {
				res := json.decode(ContractMetaData, dl.metadata) or {
					return error('Cannot decode the deployment metadata due to: ${err}')
				}
				if deployment_name == res.name {
					deployments << dl
				}
			}
		}
	}
	console.print_header('Deployments: ${deployments}')
	return deployments
}
