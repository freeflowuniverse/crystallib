#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log

fn test_get_contracts() ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mnemonics := tfgrid.get_mnemonics()!
	mut deployer := tfgrid.new_deployer(mnemonics, .dev, mut logger)!
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
