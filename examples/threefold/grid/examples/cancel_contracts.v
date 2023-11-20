module main

import freeflowuniverse.crystallib.threefold.gridproxy
import log
import freeflowuniverse.crystallib.threefold.grid

fn test_cancel_contracts(contracts_ids []u64) !{
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

fn main(){
	test_cancel_contracts([u64(47185), u64(47186)]) or {println("error happened")}
}