module main

import log
import threefoldtech.tfgrid

fn main() {
	mut logger := log.Log{
		level: .debug
	}

	mnemonics := tfgrid.get_mnemonics() or {
		logger.error(err.str())
		exit(1)
	}
	chain_network := tfgrid.ChainNetwork.dev // User your desired network
	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!

	contract_id := u64(39332) // replace with contract id that you want to cancel
	deployer.cancel_contract(contract_id)!

	logger.info('contract ${contract_id} is canceled')
}
