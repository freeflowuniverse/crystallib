#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

mut gp_client := gridproxy.get(.main, true)!

mut node_filter := model.NodeFilter{}

node_filter.status = 'up'

nodes := gp_client.get_nodes(node_filter)!
for node in nodes{

	println(node)

	println(node.capacity.total_resources.hru.to_gigabytes())

	// node_available_resources := node.calc_available_resources()
	// println(node_available_resources)

	// node_stats := gp_client.get_node_stats_by_id(node.node_id)!
	// println(node_stats)

	if true{panic("s")}

}
