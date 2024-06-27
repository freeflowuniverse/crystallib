#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import log

pub struct CloudBox{
pub mut:
	uptime_days u32
	mem_mb u32
	cpu_vcores f32
	ssd_mb u32
}

fn main() {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut gp_client := gridproxy.get(.main, true)!

	mut node_filter := model.NodeFilter{}
	node_filter.status = 'up'

	nodes := gp_client.get_nodes(node_filter)!
	for node in nodes{
		println(node)
		logger.info('${node}')
		logger.info('${node.capacity.total_resources.hru.to_gigabytes()}')

		node_available_resources := node.calc_available_resources()
		logger.info('${node_available_resources}')

		node_stats := gp_client.get_node_stats_by_id(node.node_id)!
		logger.info('${node_stats}')

		if true{panic("s")}
	}
}
