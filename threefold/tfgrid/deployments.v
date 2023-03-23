module tfgrid

import freeflowuniverse.crystallib.threefold.tfgrid
import json

// TODO: implement on grid client side

pub fn (mut client TFGridClient) deploy_deployment(deployment Deployment) !Deployment {
	result := client.rpc.call(cmd: 'deployment.create', data: json.encode(deployment))!
	return json.decode(Deployment, result)
}

pub fn (mut client TFGridClient) update_deployment(deployment Deployment) !Deployment {
	result := client.rpc.call(cmd: 'deployment.update', data: json.encode(deployment))!
	return json.decode(Deployment, result)
}

pub fn (mut client TFGridClient) cancel_deployment(deployment_id i64) ! {
	client.rpc.call(cmd: 'deployment.cancel', data: json.encode(deployment_id))!
}

pub fn (mut client TFGridClient) get_deployment(deployment_id i64) !Deployment {
	result := client.rpc.call(cmd: 'deployment.get', data: json.encode(deployment_id))!
	return json.decode(Deployment, result)
}
