module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.ui.console
import rand
import json
import encoding.base64
import os


pub fn (mut self TFDeployment) vm_deploy(args_ VMRequirements)! VMachine {
    console.print_header('Starting deployment process.')

	mut reqs := args_

    mut deployer := self.new_deployer() or {
        return error('Failed to initialize deployer: ${err}')
    }

    mut node_id := get_node_id(reqs) or {
        return error('Failed to determine node ID: ${err}')
    }

    mut network := args_.network or {
        NetworkSpecs{
            name: 'net' + rand.string(5),
            ip_range: "10.249.0.0/16",
            subnet: "10.249.0.0/24",
        }
    }

    wg_port := deployer.assign_wg_port(node_id)!
    workloads := create_workloads(args_, network, wg_port)!

    console.print_header('Creating deployment.')
    mut deployment := grid_models.new_deployment(
        twin_id: deployer.twin_id,
        description: 'VGridClient Deployment',
        workloads: workloads,
        signature_requirement: create_signature_requirement(deployer.twin_id),
    )

    console.print_header('Setting metadata and deploying workloads.')
    deployment.add_metadata("vm", reqs.name)
    contract_id := deployer.deploy(node_id, mut deployment, deployment.metadata, 0) or {
        return error('Deployment failed: ${err}')
    }

    console.print_header('Deployment successful. Contract ID: ${contract_id}')

    vm := VMachine{
        tfchain_id: "${deployer.twin_id}${reqs.name}",
        tfchain_contract_id: int(contract_id),
		requirements: reqs

    }

    self.name = reqs.name
    self.description = args_.description
    self.vms << vm

    self.save()!
    self.load(args_.name)!
    return vm
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

fn create_workloads(args_ VMRequirements, network NetworkSpecs, wg_port u32) ![]grid_models.Workload {
    mut workloads := []grid_models.Workload{}

    workloads << create_network_workload(network, wg_port)!
    mut public_ip_name := ""
    if args_.public_ip4 || args_.public_ip6 {
        public_ip_name = rand.string(5).to_lower()
        workloads << create_public_ip_workload(args_.public_ip4, args_.public_ip6, public_ip_name)
    }

    zmachine := create_zmachine_workload(args_, network, public_ip_name)!
    workloads << zmachine.to_workload(
        name: args_.name,
        description: args_.description
    )

    return workloads
}

fn create_network_workload(network NetworkSpecs, wg_port u32) !grid_models.Workload {
    console.print_header('Creating network workload.')
    return grid_models.Znet{
        ip_range: network.ip_range,
        subnet: network.subnet,
        wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=',
        wireguard_listen_port: u16(wg_port),
        mycelium: grid_models.Mycelium{
            hex_key: rand.string(32).bytes().hex(),
        },
        peers: [
            grid_models.Peer{
                subnet: network.subnet,
                wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM=',
                allowed_ips: [network.subnet],
            },
        ]
    }.to_workload(
        name: network.name,
        description: 'VGridClient Network',
    )
}

fn create_public_ip_workload(is_v4 bool, is_v6 bool, name string) grid_models.Workload {
    console.print_header('Creating Public IP workload.')
    return grid_models.PublicIP{
        v4: is_v4,
        v6: is_v6,
    }.to_workload(name: name)
}

fn create_zmachine_workload(args_ VMRequirements, network NetworkSpecs, public_ip_name string)! grid_models.Zmachine {
    console.print_header('Creating Zmachine workload.')
    mut grid_client := get()!

    return grid_models.Zmachine{
        network: grid_models.ZmachineNetwork{
            interfaces: [
                grid_models.ZNetworkInterface{
                    network: network.name,
                    ip: network.ip_range.split('/')[0],
                },
            ],
            public_ip: public_ip_name,
            planetary: args_.planetary,
            mycelium: grid_models.MyceliumIP{
                network: network.name,
                hex_seed: rand.string(6).bytes().hex(),
            },
        },
        flist: 'https://hub.grid.tf/tf-official-vms/ubuntu-24.04-latest.flist',
        entrypoint: '/sbin/zinit init',
        compute_capacity: grid_models.ComputeCapacity{
            cpu: u8(args_.cpu),
            memory: i64(args_.memory) * 1024 * 1024 * 1024,
        },
        env: {
            'SSH_KEY': grid_client.ssh_key,
        },
    }
}
