module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model as gridproxy_models

pub fn filter_nodes(filter gridproxy_models.NodeFilter) ![]gridproxy_models.Node {
	// Resolve the network configuration
	net := resolve_network()!

	// Create grid proxy client and retrieve the matching nodes
	mut gp_client := gridproxy.new(net: net, cache: true)!
	nodes := gp_client.get_nodes(filter)!
	return nodes
}
