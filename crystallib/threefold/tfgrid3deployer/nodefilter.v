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

// Applies a filter to select nodes based on the given VM requirements.
// `specs`: VMRequirements object containing the necessary specifications.
// Returns a list of nodes that match the filter.
pub fn nodefilter(specs VMRequirements) ![]gridproxy_models.Node {
	// Resolve the network configuration
	net := resolve_network()!

	// Initialize node filter and apply the given specifications
	mut myfilter := gridproxy.nodefilter()!
	myfilter.free_mru = u64(specs.memory) * 1024 * 1024 * 1024 // Convert memory to bytes
	myfilter.free_sru = u64(specs.cpu) // CPU cores
	myfilter.ipv4 = specs.public_ip4
	myfilter.ipv6 = specs.public_ip6
	myfilter.status = 'up'
	myfilter.healthy = true

	// Create grid proxy client and retrieve the matching nodes
	mut gp_client := gridproxy.new(net: net, cache: true)!
	nodes := gp_client.get_nodes(myfilter)!
	return nodes
}

// Retrieves the first healthy public node with an IPv4 address.
// Returns the first node that matches the filter.
pub fn get_access_node() !gridproxy_models.Node {
	// Initialize node filter for access nodes
	mut gpfilter := gridproxy.nodefilter()!
	net := resolve_network()!

	gpfilter.ipv4 = true // Only consider nodes with IPv4
	gpfilter.status = 'up'
	gpfilter.healthy = true

	// Create grid proxy client and retrieve the matching nodes
	mut gp_client := gridproxy.new(net: net, cache: true)!
	access_nodes := gp_client.get_nodes(gpfilter)!

	// Check if at least one node is found
	if access_nodes.len == 0 {
		return error('Cannot find a public node to assign your deployment.')
	}

	// Return the first healthy node
	return access_nodes[0]
}

// Retrieves the first healthy node.
// Returns the first node that matches the filter.
pub fn get_healthy_node() !gridproxy_models.Node {
	// Initialize node filter for healthy nodes
	mut gpfilter := gridproxy.nodefilter()!
	net := resolve_network()!

	gpfilter.status = 'up'
	gpfilter.healthy = true

	// Create grid proxy client and retrieve the matching nodes
	mut gp_client := gridproxy.new(net: net, cache: true)!
	nodes := gp_client.get_nodes(gpfilter)!

	// Check if at least one node is found
	if nodes.len == 0 {
		return error('Cannot find a public node to assign your deployment.')
	}

	// Return the first healthy node
	return nodes[0]
}
