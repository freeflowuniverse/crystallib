module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.ui.console
import rand

struct DeploymentSetup {
mut:
	wg_ports                  map[u32]u16
	wg_keys                   map[u32][]string
	wg_subnet                 map[u32]string
	endpoints                 map[u32]string
	public_node               u32
	hidden_nodes              []u32
	none_accessible_ip_ranges []string
	workloads                 map[u32][]grid_models.Workload
	name_contracts            []string

	nodes             []u32
	deployer          &grid.Deployer @[skip; str: skip]
	network_name      string
	ip_range          string
	mycelium          bool
	contracts_map     map[u32]u64
	name_contract_map map[string]u64
}

fn (mut self DeploymentSetup) setup_network_workloads(vmachines []VMachine) ! {
	// Set nodes
	for vmachine in vmachines {
		if !self.nodes.contains(vmachine.node_id) {
			self.nodes << vmachine.node_id
		}
	}

	console.print_header('Loaded nodes: ${self.nodes}.')
	self.setup_wireguard_data()!

	if self.public_node == 0 && self.hidden_nodes.len > 0 && self.nodes.len > 1 {
		/*
			- In this case a public node should be assigned.
			- We need to store it somewhere to inform the user that the deployment has one more contract on another node,
				also delete that contract when delete the full deployment.
			- Assign the public node with the new node id.
		*/
		self.setup_access_node()!
	}

	for node_id in self.nodes {
		if node_id in self.hidden_nodes {
			mut peers := self.prepare_hidden_node_peers(node_id)!
			self.set_network_workload(node_id, peers, self.mycelium)!
			continue
		}

		mut peers := self.prepare_public_node_peers(node_id)!
		self.set_network_workload(node_id, peers, self.mycelium)!
	}
}

fn (mut self DeploymentSetup) setup_wireguard_data() ! {
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

fn (mut self DeploymentSetup) setup_access_node() ! {
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

fn (mut self DeploymentSetup) calculate_subnet(idx int) !string {
	mut parts := self.ip_range.split('/')[0].split('.')
	parts[2] = '${idx}'
	return parts.join('.') + '/24'
}

fn (mut self DeploymentSetup) prepare_hidden_node_peers(node_id u32) ![]grid_models.Peer {
	mut peers := []grid_models.Peer{}
	if self.public_node != 0 {
		peers << grid_models.Peer{
			subnet:               self.wg_subnet[self.public_node]
			wireguard_public_key: self.wg_keys[self.public_node][1]
			allowed_ips:          [self.ip_range, '100.64.0.0/16']
			endpoint:             '${self.endpoints[self.public_node]}:${self.wg_ports[self.public_node]}'
		}
	}
	return peers
}

fn (mut self DeploymentSetup) prepare_public_node_peers(node_id u32) ![]grid_models.Peer {
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
			subnet:               subnet
			wireguard_public_key: self.wg_keys[peer_id][1]
			allowed_ips:          allowed_ips
			endpoint:             '${self.endpoints[peer_id]}:${self.wg_ports[peer_id]}'
		}
	}

	if node_id == self.public_node {
		for hidden_node_id in self.hidden_nodes {
			subnet := self.wg_subnet[hidden_node_id]
			routing_ip := wireguard_routing_ip(subnet)

			peers << grid_models.Peer{
				subnet:               subnet
				wireguard_public_key: self.wg_keys[hidden_node_id][1]
				allowed_ips:          [subnet, routing_ip]
				endpoint:             ''
			}
		}
	}

	return peers
}

fn (mut self DeploymentSetup) set_network_workload(node_id u32, peers []grid_models.Peer, add_mycelium bool) ! {
	mut network_workload := grid_models.Znet{
		ip_range:              self.ip_range
		subnet:                self.wg_subnet[node_id]
		wireguard_private_key: self.wg_keys[node_id][0]
		wireguard_listen_port: self.wg_ports[node_id]
		peers:                 peers
	}

	if add_mycelium {
		network_workload.mycelium = get_mycelium()
	}

	self.workloads[node_id] << network_workload.to_workload(
		name:        self.network_name
		description: 'VGridClient network workload'
	)
}

fn (mut self DeploymentSetup) setup_vm_workloads(machines []VMachine) ! {
	mut used_ip_octets := map[u32][]u8{}
	for machine in machines {
		mut req := machine.requirements
		mut public_ip_name := ''

		if req.public_ip4 || req.public_ip6 {
			public_ip_name = '${req.name}_pubip'
			self.set_public_ip_workload(req.nodes[0], public_ip_name, req)!
		}

		console.print_header('Creating Zmachine workload.')
		self.set_zmachine_workload(machine, public_ip_name, mut used_ip_octets)!
	}
}

fn (mut self DeploymentSetup) set_public_ip_workload(node_id u32, public_ip_name string, vm VMRequirements) ! {
	// Add the public IP workload
	console.print_header('Creating Public IP workload.')
	public_ip_workload := grid_models.PublicIP{
		v4: vm.public_ip4
		v6: vm.public_ip6
	}.to_workload(name: public_ip_name)

	self.workloads[node_id] << public_ip_workload
}

fn (mut self DeploymentSetup) set_zmachine_workload(vmachine VMachine, public_ip_name string, mut used_ip_octets map[u32][]u8) ! {
	mut grid_client := get()!

	zmachine_workload := grid_models.Zmachine{
		network:          grid_models.ZmachineNetwork{
			interfaces: [
				grid_models.ZNetworkInterface{
					network: self.network_name
					ip:      self.assign_private_ip(vmachine.node_id, mut used_ip_octets)!
				},
			]
			public_ip:  public_ip_name
			planetary:  vmachine.requirements.planetary
			mycelium:   if vmachine.requirements.mycelium {
				grid_models.MyceliumIP{
					network:  self.network_name
					hex_seed: rand.string(6).bytes().hex()
				}
			} else {
				none
			}
		}
		flist:            'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist'
		entrypoint:       '/sbin/zinit init'
		compute_capacity: grid_models.ComputeCapacity{
			cpu:    u8(vmachine.requirements.cpu)
			memory: i64(vmachine.requirements.memory) * 1024 * 1024 * 1024
		}
		env:              {
			'SSH_KEY': grid_client.ssh_key
		}
	}.to_workload(
		name:        vmachine.requirements.name
		description: vmachine.requirements.description
	)

	self.workloads[vmachine.node_id] << zmachine_workload
}

fn (mut self DeploymentSetup) assign_private_ip(node_id u32, mut used_ip_octets map[u32][]u8) !string {
	console.print_header('Assign private IP to node ${node_id}.')
	ip := self.wg_subnet[node_id].split('/')[0]
	mut split_ip := ip.split('.')
	last_octet := ip.split('.').last().u8()
	for candidate := last_octet + 2; candidate < 255; candidate += 1 {
		if candidate in used_ip_octets[node_id] {
			continue
		}
		split_ip[3] = '${candidate}'
		used_ip_octets[node_id] << candidate
		ip_ := split_ip.join('.')
		console.print_header('Private IP Assigned: ${ip_}.')
		return ip_
	}
	return error('failed to assign private IP in subnet: ${self.wg_subnet[node_id]}')
}

fn (mut self DeploymentSetup) finalize_deployment(deployment_name string) ! {
	for name_contract in self.name_contracts {
		name_contract_id := self.deployer.client.create_name_contract(name_contract)!
		console.print_header('name contract ${name_contract} created with id ${name_contract_id}')

		self.name_contract_map[name_contract] = name_contract_id
	}

	for node_id, workloads in self.workloads {
		console.print_header('Creating deployment on node ${node_id}.')
		mut deployment := grid_models.new_deployment(
			twin_id:               self.deployer.twin_id
			description:           'VGridClient Deployment'
			workloads:             workloads
			signature_requirement: grid_models.SignatureRequirement{
				weight_required: 1
				requests:        [
					grid_models.SignatureRequest{
						twin_id: u32(self.deployer.twin_id)
						weight:  1
					},
				]
			}
		)

		deployment.add_metadata('deployment', deployment_name)

		contract_id := self.deployer.deploy(node_id, mut deployment, deployment.metadata,
			0) or { return error('Deployment failed on node ${node_id}: ${err}') }

		// TODO: Fill the structs with the result.

		self.contracts_map[node_id] = contract_id
		console.print_header('Deployment successful. Contract ID: ${contract_id}')
	}
}

/*
	TODO's:
		# TODO:
		- add action methods e.g. delete, ping...
		- cache node and user twin ids
		- chainge the encoding/decoding behavior

		# Done:
		- return result after deployment
		- use batch calls for substrate
		- send deployments to nodes concurrently
		- add roll back behavior
*/
