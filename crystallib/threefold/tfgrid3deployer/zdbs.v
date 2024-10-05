module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
// import freeflowuniverse.crystallib.ui.console
import json

@[params]
pub struct ZDBRequirements {
pub mut:
	name        string @[required]
	password    string @[required]
	size        int    @[required]
	node_id     ?u32
	description string
	mode        grid_models.ZdbMode = 'user'
	public      bool
}

pub struct ZDB {
pub mut:
	ips          []string
	port         u32
	namespace    string
	contract_id  u64
	requirements ZDBRequirements
	node_id      u32
}

// Helper function to encode a ZDB
fn (self ZDB) encode() ![]u8 {
	return json.encode(self).bytes()
}
