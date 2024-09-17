module models

import freeflowuniverse.crystallib.threefold.grid
import log



// ContractMetaData struct to represent a deployment metadata.
pub struct ContractMetaData {
	pub mut:
		type_           string @[json: "type"]
		name 						string
		project_name  	string @[json: "projectName"]
}

// // GridMachinesModel struct to represent multiple machines in the grid
// pub struct GridMachinesModel {
// 	mnemonic      string
// 	ssh_key       string
// 	chain_network grid.ChainNetwork
// 	pub mut:
// 		client    &GridClient = unsafe { nil }
// 		node_id   int
// 		network   NetworkInfo
// 		machines  []MachineModel
// 		name      string
// 		metadata  string
// }

// // GridContracts struct to represent contracts in the grid
// pub struct GridContracts {
// 	pub mut:
// 		client 	&GridClient = unsafe { nil }
// 		network grid.ChainNetwork
// }

// // GridClient struct to represent the client interacting with the grid
// pub struct GridClient {
// 	pub mut:
// 		mnemonic      string
// 		ssh_key       string
// 		chain_network grid.ChainNetwork
// 		deployer			grid.Deployer
// 		machines      GridMachinesModel
// 		contracts     GridContracts
// }
