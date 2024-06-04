#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.threefold.grid as tfgrid
import freeflowuniverse.crystallib.threefold.griddriver { Client }
import freeflowuniverse.crystallib.ui.console
import log

fn test_get_zos_version() ! {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mnemonics := tfgrid.get_mnemonics()!
	chain_network := tfgrid.ChainNetwork.dev // User your desired network
	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!
	dst := u32(0)
	zos_version := deployer.client.get_zos_version(dst)!
	deployer.logger.info('Zos version is: ${zos_version}')
}

fn main() {
	test_get_zos_version() or { println('error happened: ${err}') }
}
