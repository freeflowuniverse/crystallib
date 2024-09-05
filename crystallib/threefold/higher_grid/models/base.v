module models
import freeflowuniverse.crystallib.threefold.grid

pub struct ComputeCapacity {
	pub mut:
	cpu int
	memory int
}

pub struct GridClient {
	pub mut:
		mnemonic string
		network grid.ChainNetwork
		vms GridVM
}

fn new_gridclient(mnemonic string, network string) !GridClient {
	chain_network := match network {
		"dev" {
			grid.ChainNetwork.dev
		}
		"qa" {
			grid.ChainNetwork.qa
		}
		"test" {
			grid.ChainNetwork.test
		}
		"main" {
			grid.ChainNetwork.main
		}
		else {
			return error("The provided chain network '${network}' does not exist.")
		}
	}

	return GridClient{
		mnemonic: mnemonic
		network: chain_network
		vms: GridVM{
			mnemonic: mnemonic
			chain_network: chain_network
		}
	}
} 