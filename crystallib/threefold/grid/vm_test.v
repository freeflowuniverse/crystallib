module grid

fn test_vm_deploy() ! {
	deployer := new_deployer('')!
	deployer.vm_deploy(
		name: 'test_vm'
		deployment_name: 'test_deployment'
	)
}