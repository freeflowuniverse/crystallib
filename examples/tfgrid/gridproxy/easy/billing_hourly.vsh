#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.gridproxy
import log

fn get_contract_billing(contract_id u64) ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mut grid_proxy := gridproxy.get(.dev, false)!
	bills := grid_proxy.get_contract_hourly_bill(contract_id)!
	logger.info('${bills}')
}

fn main() {
	contract_id := u64(119450)
	get_contract_billing(contract_id) or { println('error happened: ${err}') }
}
