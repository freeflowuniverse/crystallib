#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log

fn list_gateways() ! {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := tfgrid.get_mnemonics()!
	mut deployer := tfgrid.new_deployer(mnemonics, .dev, mut logger)!
	mut grid_proxy := gridproxy.get(.dev, false)!
	contracts := grid_proxy.get_gateways(
		status: 'up'
	)!
	deployer.logger.info('${contracts}')
	deployer.logger.info('found ${contracts.len} gateways available')
}

fn main() {
	list_gateways() or { println('error happened: ${err}') }
}
