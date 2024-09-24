module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.ui.console
import rand
import json

struct NetworkHandler {
mut:
	network_name              string
	nodes                     []u32
	ip_range                  string
	wg_ports                  map[u32]u16
	wg_keys                   map[u32][]string
	wg_subnet                 map[u32]string
	endpoints                 map[u32]string
	public_node               u32
	hidden_nodes              []u32
	none_accessible_ip_ranges []string
	mycelium                  bool

	deployer &grid.Deployer @[skip; str: skip]
}

// TODO: maybe rename to fill_network or something similar
fn (mut self NetworkHandler) create_network(vmachines []VMachine) ! {
	// Set nodes
	for vmachine in vmachines {
		if !self.nodes.contains(vmachine.node_id) {
			self.nodes << vmachine.node_id
		}
	}

	console.print_header('Loaded nodes: ${self.nodes}.')
	self.setup_wireguard_data()!

	self.setup_access_node()!
}

fn (mut self NetworkHandler) generate_workload(node_id u32, peers []grid_models.Peer, add_mycelium bool) !grid_models.Workload {
	mut network_workload := grid_models.Znet{
		ip_range: self.ip_range
		subnet: self.wg_subnet[node_id]
		wireguard_private_key: self.wg_keys[node_id][0]
		wireguard_listen_port: self.wg_ports[node_id]
		peers: peers
	}

	if add_mycelium {
		network_workload.mycelium = get_mycelium()
	}

	return network_workload.to_workload(
		name: self.network_name
		description: 'VGridClient network workload'
	)
}

fn (mut self NetworkHandler) prepare_hidden_node_peers(node_id u32) ![]grid_models.Peer {
	mut peers := []grid_models.Peer{}
	if self.public_node != 0 {
		peers << grid_models.Peer{
			subnet: self.wg_subnet[self.public_node]
			wireguard_public_key: self.wg_keys[self.public_node][1]
			allowed_ips: [self.ip_range, '100.64.0.0/16']
			endpoint: '${self.endpoints[self.public_node]}:${self.wg_ports[self.public_node]}'
		}
	}
	return peers
}

fn (mut self NetworkHandler) setup_access_node() ! {
	if self.public_node != 0 || self.hidden_nodes.len < 1 || self.nodes.len == 1 {
		return
	}

	/*
		- In this case a public node should be assigned.
		- We need to store it somewhere to inform the user that the deployment has one more contract on another node,
			also delete that contract when delete the full deployment.
		- Assign the public node with the new node id.
	*/
	console.print_header('No public nodes found based on your specs.')
	console.print_header('Requesting the Proxy to assign a public node.')

	mut myfilter := gridproxy.nodefilter()!
	myfilter.ipv4 = true // Only consider nodes with IPv4
	myfilter.status = 'up'
	myfilter.healthy = true

	nodes := filter_nodes(myfilter)!
	access_node := nodes[0]

	self.public_node = u32(access_node.node_id)
	console.print_header('Public node ${self.public_node}')

	self.nodes << self.public_node

	wg_port := self.deployer.assign_wg_port(self.public_node)!
	keys := self.deployer.client.generate_wg_priv_key()! // The first index will be the private.
	mut parts := self.ip_range.split('/')[0].split('.')
	parts[2] = '${self.nodes.len + 2}'
	subnet := parts.join('.') + '/24'

	self.wg_ports[self.public_node] = wg_port
	self.wg_keys[self.public_node] = keys
	self.wg_subnet[self.public_node] = subnet
	self.endpoints[self.public_node] = access_node.public_config.ipv4.split('/')[0]
}

fn (mut self NetworkHandler) setup_wireguard_data() ! {
	// TODO: We need to set the extra node
	console.print_header('Setting up network workload.')

	for idx, node_id in self.nodes {
		console.print_header('Assign Wireguard port for node ${node_id}.')
		self.wg_ports[node_id] = self.deployer.assign_wg_port(node_id)!

		console.print_header('Generate Wireguard keys for node ${node_id}.')
		self.wg_keys[node_id] = self.deployer.client.generate_wg_priv_key()!
		console.print_header('Wireguard keys for node ${node_id} are ${self.wg_keys[node_id]}.')

		console.print_header('Calculate subnet for node ${node_id}.')
		self.wg_subnet[node_id] = self.calculate_subnet(idx + 2)!
		console.print_header('Node ${node_id} subnet is ${self.wg_subnet[node_id]}.')

		mut public_config := self.deployer.get_node_pub_config(node_id) or {
			if err.msg().contains('no public configuration') {
				grid_models.PublicConfig{}
			} else {
				return error('Failed to get node public config: ${err}')
			}
		}

		console.print_header('Node ${node_id} public config ${public_config}.')

		if public_config.ipv4.len != 0 {
			self.endpoints[node_id] = public_config.ipv4.split('/')[0]
			self.public_node = node_id
		} else if public_config.ipv6.len != 0 {
			self.endpoints[node_id] = public_config.ipv6.split('/')[0]
		} else {
			self.hidden_nodes << node_id
			self.none_accessible_ip_ranges << self.wg_subnet[node_id]
			self.none_accessible_ip_ranges << wireguard_routing_ip(self.wg_subnet[node_id])
		}
	}
}

fn (mut self NetworkHandler) prepare_public_node_peers(node_id u32) ![]grid_models.Peer {
	mut peers := []grid_models.Peer{}
	for peer_id in self.nodes {
		if peer_id in self.hidden_nodes || peer_id == node_id {
			continue
		}

		subnet := self.wg_subnet[peer_id]
		mut allowed_ips := [subnet, wireguard_routing_ip(subnet)]

		if peer_id == self.public_node {
			allowed_ips << self.none_accessible_ip_ranges
		}

		peers << grid_models.Peer{
			subnet: subnet
			wireguard_public_key: self.wg_keys[peer_id][1]
			allowed_ips: allowed_ips
			endpoint: '${self.endpoints[peer_id]}:${self.wg_ports[peer_id]}'
		}
	}

	if node_id == self.public_node {
		for hidden_node_id in self.hidden_nodes {
			subnet := self.wg_subnet[hidden_node_id]
			routing_ip := wireguard_routing_ip(subnet)

			peers << grid_models.Peer{
				subnet: subnet
				wireguard_public_key: self.wg_keys[hidden_node_id][1]
				allowed_ips: [subnet, routing_ip]
				endpoint: ''
			}
		}
	}

	return peers
}

fn (mut self NetworkHandler) calculate_subnet(idx int) !string {
	mut parts := self.ip_range.split('/')[0].split('.')
	parts[2] = '${idx}'
	return parts.join('.') + '/24'
}

fn (mut self NetworkHandler) load_network_state(dls map[u32]&grid_models.Deployment) ! {
	// load network from deployments

	mut network_name := ''
	mut subnet_node := map[string]u32{}
	mut subnet_to_endpoint := map[string]string{}
	mut subnet_to_public_key := map[string]string{}
	for node_id, dl in dls {
		mut znet := grid_models.Znet{}
		for wl in dl.workloads {
			network_name = wl.name
			if wl.type_ == grid_models.workload_types.network {
				znet = json.decode(grid_models.Znet, wl.data)!
				break
			}
		}

		if znet.subnet == '' {
			// deployment didn't have a network workload. skip..
			continue
		}

		self.network_name = network_name
		self.nodes << node_id
		self.ip_range = znet.ip_range
		self.wg_ports[node_id] = znet.wireguard_listen_port
		self.wg_keys[node_id] = [znet.wireguard_private_key]
		self.wg_subnet[node_id] = znet.subnet
		self.mycelium = if _ := znet.mycelium { true } else { false }
		subnet_node[znet.subnet] = node_id
		for peer in znet.peers {
			subnet_to_endpoint[peer.subnet] = peer.endpoint
			subnet_to_public_key[peer.subnet] = peer.wireguard_public_key

			if peer.endpoint == '' {
				// current node is the access node
				self.public_node = node_id
			}
		}
	}

	for subnet, endpoint in subnet_to_endpoint {
		node_id := subnet_node[subnet]
		self.endpoints[node_id] = endpoint.all_after_last(':')
		if endpoint == '' {
			self.hidden_nodes << node_id
		}
	}

	for subnet, public_key in subnet_to_public_key {
		node_id := subnet_node[subnet]
		self.wg_keys[node_id] << public_key
	}

	for node_id in self.hidden_nodes {
		self.none_accessible_ip_ranges << self.wg_subnet[node_id]
		self.none_accessible_ip_ranges << wireguard_routing_ip(self.wg_subnet[node_id])
	}
}

fn (mut self NetworkHandler) generate_workloads() !map[u32]grid_models.Workload {
	mut workloads := map[u32]grid_models.Workload{}
	for node_id in self.nodes {
		if node_id in self.hidden_nodes {
			mut peers := self.prepare_hidden_node_peers(node_id)!
			workloads[node_id] = self.generate_workload(node_id, peers, self.mycelium)!
			continue
		}

		mut peers := self.prepare_public_node_peers(node_id)!
		workloads[node_id] = self.generate_workload(node_id, peers, self.mycelium)!
	}

	return workloads
}

fn (mut n NetworkHandler) remove_node(node_id u32) ! {
}

fn (mut n NetworkHandler) add_node() ! {
}
