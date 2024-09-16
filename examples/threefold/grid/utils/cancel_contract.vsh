#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log

fn test_cancel_contract(contract_id u64) ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mnemonics := tfgrid.get_mnemonics()!
	chain_network := tfgrid.ChainNetwork.dev // User your desired network
	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!
	deployer.client.cancel_contract(contract_id)!
	deployer.logger.info('contract ${contract_id} is canceled')
}

fn main() {
	test_cancel_contract(u64(119497)) or { println('error happened: ${err}') }
}
