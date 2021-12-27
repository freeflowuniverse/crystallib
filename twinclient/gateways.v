module twinclient

import json

pub fn (mut tw Client) deploy_gateway_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_fqdn', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) deploy_gateway_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_name', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_gateway_fqdn(name string) ? {
	mut msg := tw.send('twinserver.gateway.get_fqdn', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	println(response.data)
	// return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_gateway_name(name string) ? {
	mut msg := tw.send('twinserver.gateway.get_name', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	println(response.data)
	// return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_gateway_fqdn(name string) ? {
	mut msg := tw.send('twinserver.gateway.delete_fqdn', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	println(response.data)
	// return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_gateway_name(name string) ? {
	mut msg := tw.send('twinserver.gateway.delete_name', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	println(response.data)
	// return json.decode(DeployResponse, response.data) or {}
}
