module twinclient

import json

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut tw Client) deploy_gateway_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_fqdn', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut tw Client) deploy_gateway_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_name', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Get fqdn info using deployment name.
pub fn (mut tw Client) get_gateway_fqdn(name string) ?[]Deployment {
	mut msg := tw.send('twinserver.gateway.get_fqdn', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Deployment, response.data) or {}
}

// Get domain name info using deployment name
pub fn (mut tw Client) get_gateway_name(name string) ?[]Deployment {
	mut msg := tw.send('twinserver.gateway.get_name', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Deployment, response.data) or {}
}

// Delete fqdn using deployment name
pub fn (mut tw Client) delete_gateway_fqdn(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.gateway.delete_fqdn', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}

// Delete name domain on gateway using deployment name
pub fn (mut tw Client) delete_gateway_name(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.gateway.delete_name', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}
