module models

import freeflowuniverse.crystallib.threefold.grid
import log

pub struct ComputeCapacity {
	pub mut:
	cpu int
	memory int
}

// Struct Definitions
pub struct MachineNetworkAccessModel {
	pub mut:
		public_ip4   bool
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
}

pub struct GridMachinesModel {
	mnemonic      string
	ssh_key      	string
	chain_network grid.ChainNetwork
	pub mut:
		node_id   int
		network   NetworkModel
		machines  []MachineModel
		name      string
		metadata  string
}

pub struct GridClient {
	pub mut:
		mnemonic      string
		ssh_key      	string
		chain_network grid.ChainNetwork
		machiens 			GridMachinesModel
}

pub fn new_grid_client(
	mnemonic string,
	chain_network grid.ChainNetwork,
	ssh_key string,
) GridClient {
	if mnemonic.len == 0 {
		panic("Before running the script, export the `TFGRID_MNEMONIC` and point it to your wallet secret.")
	}

	if ssh_key.len == 0 {
		panic("SSH key is missing. Please export the `SSH_KEY` environment variable.")
	}

	return GridClient{
		mnemonic: mnemonic,
		chain_network: chain_network,
		ssh_key: ssh_key,
		machiens: GridMachinesModel{
			mnemonic: mnemonic,
			chain_network: chain_network,
			ssh_key: ssh_key,
		}
	}
}
__global logger = init_logger()

fn init_logger() &log.Log {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	return logger
}
