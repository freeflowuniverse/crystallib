module twinclient

import json

pub struct GatewayFQDN {
	name string
	node_id u32
	fqdn string
	tls_passthrough bool
	backends []string
}

pub struct GatewayName {
	name string
	node_id u32
	tls_passthrough bool
	backends []string
}

pub fn (mut tw Client) deploy_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_fqdn', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) deploy_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.gateway.deploy_name', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}