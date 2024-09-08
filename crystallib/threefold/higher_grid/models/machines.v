module models

import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import rand
import log


// Struct Definitions
pub struct MachineNetworkAccessModel {
	pub mut:
		public_ip   bool
		public_ip6  bool
		planetary   bool
		mycelium    bool
}

pub struct NetworkModel {
	pub mut:
		name     string
		ip_range string
		subnet   string
}

pub struct MachineModel {
	pub mut:
		name          string
		deployment_name string
		network_access MachineNetworkAccessModel
		capacity      ComputeCapacity
		pub_sshkeys   []string
}

pub struct GridVM {
	mnemonic      string
	chain_network grid.ChainNetwork
	pub mut:
		network   NetworkModel
		machines  []MachineModel
		name      string
		metadata  string
}

// Helper function to concatenate SSH keys
fn build_ssh_key_string(sshkeys []string) string {
	logger.info('Exporting the SSH keys.')
	return sshkeys.join("\n")
}

// Helper function to create a Zmachine workload
fn create_zmachine_workload(machine MachineModel, network NetworkModel, pub_sshkeys string) grid_models.Zmachine {
	logger.info('Creating the Zmachine workload.')
	return grid_models.Zmachine{
		flist: 'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist',
		network: grid_models.ZmachineNetwork{
			public_ip: '',
			interfaces: [
				grid_models.ZNetworkInterface{
					network: network.name,
					ip: network.ip_range.split('/')[0],
				},
			],
			planetary: machine.network_access.planetary,
			mycelium: grid_models.MyceliumIP{
				network: network.name,
				hex_seed: rand.string(6).bytes().hex(),
			}
		},
		entrypoint: '/sbin/zinit init',
		compute_capacity: grid_models.ComputeCapacity{
			cpu: u8(machine.capacity.cpu),
			memory: i64(machine.capacity.memory) * 1024 * 1024,
		},
		env: {
			'SSH_KEY': pub_sshkeys,
		}
	}
}

// Main deploy function
pub fn (mut grid_vm GridVM) deploy(config GridConfig) ! {
	logger.info('Starting deployment process.')
	mut deployer := grid.new_deployer(config.mnemonic, config.chain_network)!

	mut workloads := []grid_models.Workload{}
	wg_port := deployer.assign_wg_port(u32(config.node_id))!

	// Create network workload
	workloads << create_network_workload(grid_vm, wg_port)

	// SSH keys
	ssh_key_str := build_ssh_key_string(grid_vm.machines[0].pub_sshkeys)

	// Machine workloads
	for machine in grid_vm.machines {
		if machine.network_access.public_ip {
			public_ip_name := rand.string(5).to_lower()
			workloads << create_public_ip_workload(machine.network_access.public_ip, public_ip_name)
		}
		workloads << create_zmachine_workload(machine, grid_vm.network, ssh_key_str).to_workload(
			name: 'vm_${rand.string(5).to_lower()}',
			description: 'VGridClient Zmachine'
		)
	}

	if ssh_key_str.len == 0 {
		logger.warn("No SSH key set. You won't be able to access your deployment without it.")
	}

	// Deployment
	logger.info('Creating deployment object.')
	mut deployment := grid_models.new_deployment(
		twin_id: deployer.twin_id,
		description: 'VGridClient Deployment',
		workloads: workloads,
		signature_requirement: create_signature_requirement(deployer.twin_id),
	)

	log_and_set_metadata(mut logger, mut deployment, 'vm', 'SimpleVM')

	// Deploy the workloads
	logger.info('Deploying workloads...')
	contract_id := deployer.deploy(u32(config.node_id), mut deployment, deployment.metadata, 0) or {
		logger.error('Deployment failed: ${err}')
		return err
	}
	logger.info('Deployment successful. Contract ID: ${contract_id}')
}

// Helper function to create a network workload
fn create_network_workload(grid_vm GridVM, wg_port u32) grid_models.Workload {
	logger.info('Creating the network workload.')
	return grid_models.Znet{
		ip_range: grid_vm.network.ip_range,
		subnet: grid_vm.network.subnet,
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=',
		wireguard_listen_port: u16(wg_port),
		mycelium: grid_models.Mycelium{
			hex_key: rand.string(32).bytes().hex(),
		},
		peers: [
			grid_models.Peer{
				subnet: grid_vm.network.subnet,
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM=',
				allowed_ips: [grid_vm.network.subnet,],
			},
		]
	}.to_workload(
		name: grid_vm.network.name,
		description: 'VGridClient Network',
	)
}

// Helper function to create public IP workload
fn create_public_ip_workload(public_ip bool, name string) grid_models.Workload {
	logger.info('Setting the PublicIPV4 metadata.')
	return grid_models.PublicIP{
		v4: public_ip,
	}.to_workload(name: name)
}

// Helper function to create signature requirements
fn create_signature_requirement(twin_id int) grid_models.SignatureRequirement {
	logger.info('Setting the signature requirement.')
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

// Helper function to log and set metadata
fn log_and_set_metadata(mut logger &log.Log, mut deployment grid_models.Deployment, key string, value string) {
	logger.info('Setting ${key} metadata.')
	deployment.add_metadata(key, value)
}

// Not implemented functions
pub fn (mut grid_vm GridVM) delete() {
	println("Not Implemented")
}

pub fn (mut grid_vm GridVM) get() {
	println("Not Implemented")
}

pub fn (mut grid_vm GridVM) update() {
	println("Not Implemented")
}
