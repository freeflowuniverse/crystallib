module tfgrid


pub fn (mut client TFGridClient) deploy_deployment(deployment Deployment) !Deployment {
	retqueue := client.rpc.call[Deployment]('tfgrid.deployment.create', deployment)!
	return client.rpc.result[Deployment](5000, retqueue)!
}

pub fn (mut client TFGridClient) update_deployment(deployment Deployment) !Deployment {
	retqueue := client.rpc.call[Deployment]('tfgrid.deployment.update', deployment)!
	return client.rpc.result[Deployment](5000, retqueue)!
}

pub fn (mut client TFGridClient) cancel_deployment(deployment_id i64) ! {
	retqueue := client.rpc.call[i64]('tfgrid.deployment.cancel', deployment_id)!
	_ := client.rpc.result[string](5000, retqueue)!
}

pub fn (mut client TFGridClient) get_deployment(deployment_id i64) !Deployment {
	retqueue := client.rpc.call[i64]('tfgrid.deployment.get', deployment_id)!
	return client.rpc.result[Deployment](5000, retqueue)!
}
