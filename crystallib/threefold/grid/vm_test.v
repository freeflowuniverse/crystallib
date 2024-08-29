module grid

import freeflowuniverse.crystallib.installers.tfgrid.griddriver

fn testsuite_begin() ! {
	griddriver.install()!
}

fn test_vm_deploy() ! {
	mneumonics := os.getenv('MNEUMONICS')
	ssh_key := os.getenv('SSH_KEY')

	chain_network := grid.ChainNetwork.main // User your desired network
	mut deployer := new_deployer(mneumonics, chain_network)!
	deployer.vm_deploy(
		name: 'test_vm'
		deployment_name: 'test_deployment'
		nodeid: 24
		pub_sshkeys: [ssh_key]
	)!
}