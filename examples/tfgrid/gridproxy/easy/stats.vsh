#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy

fn get_online_grid_stats_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	grid_online_stats := gp_client.get_stats(status: .online)!
	println(grid_online_stats)
}

fn get_all_grid_stats_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	grid_all_stats := gp_client.get_stats(status: .all)!
	println(grid_all_stats)
}

get_online_grid_stats_example()!
get_all_grid_stats_example()!
