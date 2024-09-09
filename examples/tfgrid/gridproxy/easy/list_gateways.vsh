#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import log

fn list_gateways() ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut grid_proxy := gridproxy.get(.dev, false)!
	contracts := grid_proxy.get_gateways(
		status: 'up'
	)!
	logger.info('${contracts}')
	logger.info('found ${contracts.len} gateways available')
}

list_gateways() or { println('error happened: ${err}') }
