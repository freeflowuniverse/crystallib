module tfgrid3deployer

import rand
import json
import freeflowuniverse.crystallib.threefold.grid.models

@[params]
pub struct WebNameRequirements {
pub mut:
	name    string @[required]
	node_id u32
	// must be in the format ip:port if tls_passthrough is set, otherwise the format should be http://ip[:port]
	backend         string @[required]
	tls_passthrough bool
}

pub struct WebNameResult {
pub mut:
	fqdn             string
	name_contract_id u64
	node_contract_id u64
	requirements     WebNameRequirements
	node_id          u32
}

fn (mut self DeploymentSetup) setup_webname_workloads(mut webnames []WebNameResult) ! {
	for wn in webnames {
		mut req := wn.requirements

		gw_name := if req.name == '' {
			req.name = rand.string(5).to_lower()
			req.name
		} else {
			req.name
		}

		gw := models.GatewayNameProxy{
			tls_passthrough: req.tls_passthrough
			backends:        [req.backend]
			name:            gw_name
		}

		self.workloads[wn.node_id] << gw.to_workload(name: gw_name)
		self.name_contracts << gw_name
	}
}

// Helper function to encode a WebNameResult
fn (self WebNameResult) encode() ![]u8 {
	return json.encode(self).bytes()
}
