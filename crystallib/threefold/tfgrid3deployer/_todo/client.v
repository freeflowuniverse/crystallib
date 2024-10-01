module models

import freeflowuniverse.crystallib.threefold.grid
import log

// GridClient struct to represent the client interacting with the grid
pub struct Deployment {
mut:
	deployer grid.Deployer
pub mut:
	mnemonic      string
	ssh_key       string
	chain_network grid.ChainNetwork
	machines      GridMachinesModel
	contracts     GridContracts
}
