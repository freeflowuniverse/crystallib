module main

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.grid
import log

fn list_gateways() ! {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := grid.get_mnemonics()!
	mut deployer := grid.new_deployer(mnemonics, .dev, mut logger)!
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
