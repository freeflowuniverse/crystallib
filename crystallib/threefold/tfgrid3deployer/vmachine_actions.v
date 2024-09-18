module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.ui.console
import rand
import json
import encoding.base64
import os

pub fn (mut self TFDeployment) deploy()!{
	console.print_header('Starting deployment process.')

	// 1. Loop over all of the VMs
	// 2. Get node for each VMs if not passed
	// 3. Create network per node
	// 4. Manage the VM IPs
	// 5. Deploy each VM

	mut nodes := []u32{}
	mut network := self.network or {
		NetworkSpecs{
			name:     'net' + rand.string(5)
			ip_range: '10.10.0.0/16'
		}
	}

	self.network = network

	// Get the nodes of the deployment to create the network.
	for mut vm in self.vms {
		mut node_id := get_node_id(vm.requirements) or {
			return error('Failed to determine node ID: ${err}')
		}
		vm.requirements.nodes << node_id
		nodes << node_id
	}

	console.print_header('Loaded nodes are ${nodes}.')

	/*
		1. Per node we need to:
				- Get the wiregurd port
				- Generate a wireguard private key
				- Assign a subnet
				- Assign the Peers

				// Result will be like this
				{
						<nodeId>: {
								wg_port: int,
								keys: []string,
								subnet: string,
						}
				}
	*/

	mut wg_ports := map[u32]u16{}
	mut wg_keys := map[u32][]string{}
	mut wg_subnet := map[u32]string{}
	mut node_endpoints := map[u32]string{}
	mut hidden_nodes := []u32{}
	mut public_node := u32(0)
	mut none_accessible_ip_ranges := []string{}
	mut workloads := map[u32][]grid_models.Workload{}

	console.print_header('Setup the network workload.')
	// Set the network data
	for idx, node_id in nodes {
		wg_port := self.deployer.assign_wg_port(node_id)!
		keys := self.deployer.client.generate_wg_priv_key()! // The first index will be the private.
		mut parts := network.ip_range.split('/')[0].split('.')
		parts[2] = '${idx + 2}'
		subnet := parts.join('.') + '/24'

		wg_ports[node_id] = wg_port
		wg_keys[node_id] = keys
		wg_subnet[node_id] = subnet

		pc := self.deployer.get_node_pub_config(node_id) or {
			if err.msg().contains('no public configuration') {
				grid_models.PublicConfig{}
			} else {
				return error('Faild to get node public config due to: ${err}')
			}
		}

		if pc.ipv4.len != 0 {
			node_endpoints[node_id] = pc.ipv4.split('/')[0]
			public_node = node_id
		} else if pc.ipv6.len != 0 {
			node_endpoints[node_id] = pc.ipv6.split('/')[0]
		} else {
			// This node is hidden node.
			hidden_nodes << node_id
			none_accessible_ip_ranges << subnet
			none_accessible_ip_ranges << wireguard_routing_ip(subnet)
		}
	}

	if hidden_nodes.len == nodes.len && nodes.len > 1 {
		/*
			- In this case a public node should be assigned.
			- We need to store it somewhere to inform the user that the deployment has one more contract on other node,
				also delete that contract when delete the full deployment.
			- Assign the public node with the new node id.
		*/

		console.print_header('No public nodes found based on your specs.')
		console.print_header('Requesting the Proxy to assign a public node.')

		mut gpfilter := gridproxy.nodefilter()!
		net := resolve_network()!

		gpfilter.ipv4 = true
		gpfilter.status = 'up'
		gpfilter.healthy = true

		mut gp_client := gridproxy.new(net: net, cache: true)!
		access_nodes := gp_client.get_nodes(gpfilter)!

		if access_nodes.len == 0 {
			return error('Cannot find a public node to assign your deployment.')
		}

		public_node = u32(access_nodes[0].node_id)
		nodes << public_node

		wg_port := self.deployer.assign_wg_port(public_node)!
		keys := self.deployer.client.generate_wg_priv_key()! // The first index will be the private.
		mut parts := network.ip_range.split('/')[0].split('.')
		parts[2] = '${nodes.len + 2}'
		subnet := parts.join('.') + '/24'

		wg_ports[public_node] = wg_port
		wg_keys[public_node] = keys
		wg_subnet[public_node] = subnet
	}

	for idx, node_id in nodes {
		if node_id in hidden_nodes {
			// List of peers
			// if Public node -> the peers will point to the public node
			mut peers := []grid_models.Peer{}
			endpoint := '${node_endpoints[public_node]}:${wg_ports[public_node]}'

			if public_node != 0 {
				peers << grid_models.Peer{
					subnet:               wg_subnet[public_node]
					wireguard_public_key: wg_keys[public_node][1]
					allowed_ips:          [network.ip_range, '100.64.0.0/16']
					endpoint:             endpoint
				}
			}

			mut network_workload := grid_models.Znet{
				ip_range:              network.ip_range
				subnet:                wg_subnet[node_id]
				wireguard_private_key: wg_keys[node_id][0]
				wireguard_listen_port: wg_ports[node_id]
				peers:                 peers
			}

			if network.mycelium {
				network_workload.mycelium = get_mycelium()
			}

			workloads[node_id] << network_workload.to_workload(
				name:        network.name
				description: 'VGridClient Network'
			)

			continue
		}

		// Set the Peers
		mut peers := []grid_models.Peer{}

		for peer_id in nodes {
			if peer_id in hidden_nodes || peer_id == node_id {
				continue
			}

			subnet := wg_subnet[peer_id]
			mut allowed_ips := [subnet]
			allowed_ips << wireguard_routing_ip(subnet)

			if peer_id == public_node {
				allowed_ips << wireguard_routing_ip(subnet)
				allowed_ips << none_accessible_ip_ranges
			}

			endpoint := '${node_endpoints[peer_id]}:${wg_ports[peer_id]}'

			peers << grid_models.Peer{
				subnet:               subnet
				wireguard_public_key: wg_keys[peer_id][1]
				allowed_ips:          allowed_ips
				endpoint:             endpoint
			}
		}

		if node_id == public_node {
			for hidden_node_id in hidden_nodes {
				subnet := wg_subnet[hidden_node_id]
				routing_ip := wireguard_routing_ip(subnet)

				peers << grid_models.Peer{
					subnet:               subnet
					wireguard_public_key: wg_keys[hidden_node_id][1]
					allowed_ips:          [subnet, routing_ip]
					endpoint:             ''
				}
			}
		}

		mut network_workload := grid_models.Znet{
			ip_range:              network.ip_range
			subnet:                wg_subnet[node_id]
			wireguard_private_key: wg_keys[node_id][0]
			wireguard_listen_port: wg_ports[node_id]
			peers:                 peers
			mycelium:              grid_models.Mycelium{
				hex_key: rand.string(32).bytes().hex()
				peers:   []
			}
		}.to_workload(
			name:        network.name
			description: 'VGridClient Network'
		)

		workloads[node_id] << network_workload
	}

	// Creating the ZMachine workloads
	for vmachine in self.vms {
		mut vm := vmachine.requirements
		mut public_ip_name := ''

		if vm.public_ip4 || vm.public_ip6 {
			public_ip_name = rand.string(5).to_lower()
			console.print_header('Creating Public IP workload.')
			public_ip_workload := grid_models.PublicIP{
				v4: vm.public_ip4
				v6: vm.public_ip6
			}.to_workload(name: public_ip_name)

			workloads[vm.nodes[0]] << public_ip_workload
		}

		console.print_header('Creating Zmachine workload.')
		mut grid_client := get()!

		zmachine_workload := grid_models.Zmachine{
			network: grid_models.ZmachineNetwork{
				interfaces: [
					grid_models.ZNetworkInterface{
						network: network.name
						ip: network.ip_range.split('/')[0]
					},
				]
				public_ip: public_ip_name
				planetary: vm.planetary
				mycelium:  if vm.mycelium { grid_models.MyceliumIP{
						network:  network.name
						hex_seed: rand.string(6).bytes().hex()
					}
				 } else { none }
			}
			flist: 'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist'
			entrypoint: '/sbin/zinit init'
			compute_capacity: grid_models.ComputeCapacity{
				cpu: u8(vm.cpu)
				memory: i64(vm.memory) * 1024 * 1024 * 1024
			}
			env: {
				'SSH_KEY': grid_client.ssh_key
			}
		}.to_workload(
			name: vm.name
			description: vm.description
		)

		workloads[vm.nodes[0]] << zmachine_workload
	}

	mut contracts_map := map[u32]u64{}

	for node_id, workloads_value in workloads {
		console.print_header('Creating deployment.')
		mut deployment := grid_models.new_deployment(
			twin_id: self.deployer.twin_id,
			description: 'VGridClient Deployment',
			workloads: workloads_value,
			signature_requirement: create_signature_requirement(self.deployer.twin_id),
		)

		console.print_header('Setting metadata and deploying workloads.')
		deployment.add_metadata("vm", self.name)
		contract_id := self.deployer.deploy(node_id, mut deployment, deployment.metadata, 0) or {
			return error('Deployment failed: ${err}')
		}
		contracts_map[node_id] = contract_id
		console.print_header('Deployment successful. Contract ID: ${contract_id}')
	}

	for mut vm in self.vms {
		vm.tfchain_contract_id = contracts_map[vm.requirements.nodes[0]]
	}

	self.save()!
}

fn get_node_id(args_ VMRequirements) !u32 {
	if args_.nodes.len == 0 {
		console.print_header('Requesting the proxy to filter nodes.')
		nodes := nodefilter(args_)!
		if nodes.len == 0 {
			return error('No suitable nodes found.')
		}
		return u32(nodes[0].node_id)
	}
	return u32(args_.nodes[0])
}

fn create_signature_requirement(twin_id int) grid_models.SignatureRequirement {
    console.print_header('Setting signature requirement.')
    return grid_models.SignatureRequirement{
        weight_required: 1,
        requests: [
            grid_models.SignatureRequest{
                twin_id: u32(twin_id),
                weight: 1,
            },
        ],
    }
}