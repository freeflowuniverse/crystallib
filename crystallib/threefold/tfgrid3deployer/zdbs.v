module tfgrid3deployer

import json
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct ZDBRequirements {
pub mut:
	name        string              @[required]
	password    string              @[required]
	size        int                 @[required]
	node_id     u32
	description string
	mode        grid_models.ZdbMode = 'user'
	public      bool
}

pub struct ZDBResult {
pub mut:
	ips          []string
	port         string
	namespace    string
	contract_id  string
	requirements ZDBRequirements
}

// Sets up Zero-DB (ZDB) workloads for deployment.
//
// This function takes a list of ZDB results, processes each result into a ZDB workload model,
// assigns it to a healthy node, and then adds it to the deployment workloads.
//
// `zdbs`: A list of ZDBResult objects containing the ZDB requirements.
//
// Each ZDB is processed to convert the requirements into a grid workload and associated with a healthy node.
fn (mut self DeploymentSetup) setup_zdb_workloads(zdbs []ZDBResult) ! {
	for zdb_result in zdbs {
		// Retrieve ZDB requirements from the result
		mut zdb := zdb_result.requirements
		console.print_header('Creating a ZDB workload for `${zdb.name}` DB.')

		// Create the Zdb model with the size converted to bytes
		zdb_model := grid_models.Zdb{
			size: u64(zdb.size) * 1024 * 1024 // Convert size from MB to bytes
			mode: zdb.mode
			public: zdb.public
			password: zdb.password
		}

		// Generate a workload based on the Zdb model
		zdb_workload := zdb_model.to_workload(
			name: zdb.name
			description: zdb.description
		)

		if zdb.node_id == 0 {
			// Retrieve a healthy node for deployment
			node := get_healthy_node()!
			zdb.node_id = u32(node.node_id)
		}

		// Append the workload to the node's workload list in the deployment setup
		self.workloads[zdb.node_id] << zdb_workload
	}
}
