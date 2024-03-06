#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn get_nodes_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	mut node_filter := model.NodeFilter{}

	node_filter.status = 'up'
	node_filter.country = 'egypt'
	node_filter.free_ips = u64(4)

	nodes := gp_client.get_nodes(node_filter)!
	println(nodes)
}

fn get_node_by_id_example(node_id u64) ! {
	mut gp_client := gridproxy.get(.dev, true)!

	node := gp_client.get_node_by_id(node_id)!

	// get node available resources
	node_available_resources := node.calc_available_resources()
	println(node_available_resources)
}

fn get_node_stats_by_id(node_id u64) ! {
	mut gp_client := gridproxy.get(.dev, true)!

	node_stats := gp_client.get_node_stats_by_id(node_id)!
	println(node_stats)
}

fn get_nodes_iterator_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	max_page_iteration := u64(5) // set maximum pages to iterate on

	mut node_iterator := gp_client.get_nodes_iterator(status: 'up')
	mut iterator_available_node := []model.Node{}
	for {
		if node_iterator.filter.page is u64 && node_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_nodes := node_iterator.next()
		if iterator_nodes != none {
			iterator_available_node << iterator_nodes
		} else {
			break // if the page is empty the next function will return none
		}
	}
	println(iterator_available_node)
}

fn get_node_by_resources_filter_example() ! {
	// init gridproxy client on devnet with redis cash
	mut gp_client := gridproxy.get(.dev, true)!

	// using resource filter

	resources := model.ResourceFilter{
		free_sru_gb: 1 // gb
		free_hru_gb: 0
		free_mru_gb: 0
		free_ips: 0
	}

	node_has_resources := gp_client.get_nodes_has_resources(resources)
	nodes_have_resources := node_has_resources.get_func()!
	println(nodes_have_resources.len)
}

fn main() {
	get_nodes_example()!
	get_node_by_id_example(u64(11))!
	get_node_stats_by_id(u64(11))!
	get_nodes_iterator_example()!
	get_node_by_resources_filter_example()!
}
