#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log

fn test_cancel_contracts(contracts_ids []u64) ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mnemonics := tfgrid.get_mnemonics()!
	mut deployer := tfgrid.new_deployer(mnemonics, .dev, mut logger)!
	for cont_id in contracts_ids {
		deployer.client.cancel_contract(cont_id)!
		deployer.logger.info('contract ${cont_id} is canceled')
	}
}

fn main() {
	test_cancel_contracts([u64(119493), u64(119492)]) or { println('error happened: ${err}') }
}
