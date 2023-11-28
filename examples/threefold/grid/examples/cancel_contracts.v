module main

import log
import freeflowuniverse.crystallib.threefold.grid

fn test_cancel_contracts(contracts_ids []u64) ! {
	mut logger := log.Log{
		level: .debug
	}
	mnemonics := grid.get_mnemonics()!
	mut deployer := grid.new_deployer(mnemonics, .dev, mut logger)!
	for cont_id in contracts_ids {
		deployer.client.cancel_contract(cont_id)!
		deployer.logger.info('contract ${cont_id} is canceled')
	}
}

fn main() {
	test_cancel_contracts([u64(47218), u64(47219)]) or { println('error happened: ${err}') }
}
