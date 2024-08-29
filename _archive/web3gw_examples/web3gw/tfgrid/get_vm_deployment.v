module main

import freeflowuniverse.crystallib.threefold.web3gw.tfgrid
import os

fn do() ! {
	mut tfgrid_client := tfgridclient_example()!

	// vm_deployment := tfgrid_client.get_vm_deployment(...)!
	// tfgrid_client.logger.info('${vm_deployment}')
}

fn main() {
	do() or { panic(err) }
}
