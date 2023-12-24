module main

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import freeflowuniverse.crystallib.threefold.grid
import log

fn test_get_contracts() ! {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := grid.get_mnemonics()!
	mut deployer := grid.new_deployer(mnemonics, .dev, mut logger)!
	mut grid_proxy := gridproxy.get(.dev, false)!
	contracts := grid_proxy.get_contracts(
		twin_id: model.OptionU64(u64(deployer.twin_id))
		state: 'created'
	)!
	deployer.logger.info('${contracts}')
}

fn main() {
	test_get_contracts() or { println('error happened: ${err}') }
}
