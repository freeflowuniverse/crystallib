module tfgrid3deployer

import rand
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
	fqdn                string
	name_contract_id    u64
	tfchain_contract_id u64
	requirements        WebNameRequirements
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
			backends: [req.backend]
			name: gw_name
		}

		mut gw_node_id := req.node_id
		if gw_node_id == 0 {
			nodes := filter_nodes(domain: true, status: 'up', healthy: true)!
			gw_node_id = u32(nodes[0].node_id)
		}

		self.workloads[gw_node_id] << gw.to_workload(name: gw_name)
		self.name_contracts << gw_name
	}
}
