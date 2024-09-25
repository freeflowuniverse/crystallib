module tfgrid3deployer

import json

@[params]
pub struct WebNameRequirements {
pub mut:
	name    				string @[required]
	node_id 				?u32
	// must be in the format ip:port if tls_passthrough is set, otherwise the format should be http://ip[:port]
	backend         string @[required]
	tls_passthrough bool
}

pub struct WebName {
pub mut:
	fqdn             string
	name_contract_id u64
	node_contract_id u64
	requirements     WebNameRequirements
	node_id          u32
}

// Helper function to encode a WebName
fn (self WebName) encode() ![]u8 {
	return json.encode(self).bytes()
}
