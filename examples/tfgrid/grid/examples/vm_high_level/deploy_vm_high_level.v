module main

import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import log
import os

fn main() {
	mut logger := &log.Log{}
	logger.set_level(.debug)
	mnemonics := os.getenv('MNEMONICS')
	chain_network := tfgrid.ChainNetwork.dev // User your desired network
	mut deployer := tfgrid.new_deployer(mnemonics, chain_network, mut logger)!
	vm := models.new_vm('vm1', { 'SSH_KEY': 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTwULSsUubOq3VPWL6cdrDvexDmjfznGydFPyaNcn7gAL9lRxwFbCDPMj7MbhNSpxxHV2+/iJPQOTVJu4oc1N7bPP3gBCnF51rPrhTpGCt5pBbTzeyNweanhedkKDsCO2mIEh/92Od5Hg512dX4j7Zw6ipRWYSaepapfyoRnNSriW/s3DH/uewezVtL5EuypMdfNngV/u2KZYWoeiwhrY/yEUykQVUwDysW/xUJNP5o+KSTAvNSJatr3FbuCFuCjBSvageOLHePTeUwu6qjqe+Xs4piF1ByO/6cOJ8bt5Vcx0bAtI8/MPApplUU/JWevsPNApvnA/ntffI+u8DCwgP' })
	res := deployer.client.deploy_single_vm(129, 'myproject', vm, deployer.env)!
	println(res)
}
