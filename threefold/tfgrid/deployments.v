module tfgrid

import freeflowuniverse.crystallib.threefold.tfgrid
import json

// TODO: implement on grid client side

pub fn (mut client TFGridClient) deploy_deployment(deployment Deployment) !Deployment {
	response := client.rpc.call(cmd: 'deployment.create', data: json.encode(deployment))!
	if response.error != '' {
		return error(response.error)
	}
	return json.decode(Deployment, response.result)
}

pub fn (mut client TFGridClient) update_deployment(deployment Deployment) !Deployment {
	response := client.rpc.call(cmd: 'deployment.update', data: json.encode(deployment))!
	if response.error != '' {
		return error(response.error)
	}
	return json.decode(Deployment, response.result)
}

pub fn (mut client TFGridClient) cancel_deployment(deployment_id i64) ! {
	response := client.rpc.call(cmd: 'deployment.cancel', data: json.encode(deployment_id))!
	if response.error != '' {
		return error(response.error)
	}
}

pub fn (mut client TFGridClient) get_deployment(deployment_id i64) !Deployment {
	response := client.rpc.call(cmd: 'deployment.get', data: json.encode(deployment_id))!
	if response.error != '' {
		return error(response.error)
	}
	return json.decode(Deployment, response.result)
}
