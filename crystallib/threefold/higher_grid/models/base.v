module models

import freeflowuniverse.crystallib.threefold.grid
import log

// ComputeCapacity struct to represent CPU and memory allocation
pub struct ComputeCapacity {
	pub mut:
		cpu    int
		memory int
}

// MachineNetworkAccessModel struct to represent network access configuration
pub struct MachineNetworkAccessModel {
	pub mut:
		public_ip4  bool
		public_ip6  bool
		planetary   bool
		mycelium    bool
}

// NetworkModel struct to represent network details
pub struct NetworkModel {
	pub mut:
		name     string
		ip_range string
		subnet   string
}

// MachineModel struct to represent a machine and its associated details
pub struct MachineModel {
	pub mut:
		name            string
		deployment_name string
		network_access  MachineNetworkAccessModel
		capacity        ComputeCapacity
}

// GridMachinesModel struct to represent multiple machines in the grid
pub struct GridMachinesModel {
	mnemonic      string
	ssh_key       string
	chain_network grid.ChainNetwork
	pub mut:
		client        &GridClient = unsafe { nil } // Reference to GridClient, initially nil
		node_id   int
		network   NetworkModel
		machines  []MachineModel
		name      string
		metadata  string
}

// GridContractsModel struct to represent contracts in the grid
pub struct GridContractsModel {
	pub mut:
		client &GridClient = unsafe { nil } // Reference to GridClient, initially nil
		network grid.ChainNetwork
}

// GridZosModel struct to represent contracts in the grid
pub struct GridContractsModel {
	pub mut:
		client &GridClient = unsafe { nil } // Reference to GridClient, initially nil
		network grid.ChainNetwork
}

// GridClient struct to represent the client interacting with the grid
pub struct GridClient {
	pub mut:
		mnemonic      string
		ssh_key       string
		chain_network grid.ChainNetwork
		deployer			grid.Deployer
		machines      GridMachinesModel
		contracts     GridContractsModel
}

// Function to initialize a new GridClient instance
pub fn new_grid_client(
	mnemonic string,
	chain_network grid.ChainNetwork,
	ssh_key string,
) !GridClient {
	// Ensure mnemonic is provided
	if mnemonic.len == 0 {
		return error('Please export the `TFGRID_MNEMONIC` and point it to your wallet secret.')
	}

	// Ensure SSH key is provided
	if ssh_key.len == 0 {
		return error('SSH key is missing. Please export the `SSH_KEY` environment variable.')
	}

	// Initialize the GridClient
	mut client := GridClient{
		mnemonic: mnemonic
		chain_network: chain_network
		ssh_key: ssh_key
		machines: GridMachinesModel{
			mnemonic: mnemonic
			chain_network: chain_network
			ssh_key: ssh_key
		}
		contracts: GridContractsModel{
			network: chain_network
		}
	}

	// Set the GridClient reference in GridMachinesModel and GridContractsModel
	logger.debug('Initializing Deployer instance')
	mut deployer := grid.new_deployer(client.mnemonic, client.chain_network)!
	client.deployer = deployer
	client.machines.client = &client
	client.contracts.client = &client
	logger.debug('Deployer Twin ID: ${deployer.twin_id}')

	return client
}

// Global logger initialization
__global logger = init_logger()

fn init_logger() &log.Log {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	return logger
}
