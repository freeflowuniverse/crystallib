#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import log

fn get_online_grid_stats_example() ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut gp_client := gridproxy.get(.dev, true)!

	grid_online_stats := gp_client.get_stats(status: .online)!
	logger.info('${grid_online_stats}')
}

fn get_all_grid_stats_example() ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut gp_client := gridproxy.get(.dev, true)!

	grid_all_stats := gp_client.get_stats(status: .all)!
	logger.info('${grid_all_stats}')
}

fn main() {
	get_online_grid_stats_example()!
	get_all_grid_stats_example()!
}