#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import log

fn main() {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut gp_client := gridproxy.get(.test, true)!
	farms := gp_client.get_farms()!
	// println(farms)

	// get gateway list
	gateways := gp_client.get_gateways()!
	// get contract list
	contracts := gp_client.get_contracts()!
	// get grid stats
	stats := gp_client.get_stats()!
	// println(stats)
	// get twins
	twins := gp_client.get_twins()!

	// get node list
	nodes := gp_client.get_nodes(dedicated: true, free_ips: u64(1))!
	logger.info('${nodes}')
}
