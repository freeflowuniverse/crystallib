module tfgrid

import json

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut client TFGridClient) gateways_deploy_fqdn(payload GatewayFQDN) !GatewayFQDNResult {
	payload_encoded := json.encode_pretty(payload)
	response := client.rpc.call(cmd: 'gateway.fqdn.deploy', data: payload_encoded)!
	return json.decode(GatewayFQDNResult, response)
}

// Get fqdn info using deployment name.
pub fn (mut client TFGridClient) gateways_get_fqdn(name string) !GatewayFQDNResult {
	response := client.rpc.call(cmd: 'gateway.fqdn.get', data: name)!

	return json.decode(GatewayFQDNResult, response)
}


// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut client TFGridClient) gateways_deploy_name(payload GatewayName) !GatewayNameResult {
	payload_encoded := json.encode_pretty(payload)
	response := client.rpc.call(cmd: 'gateway.name.deploy', data: payload_encoded)!
	return json.decode(GatewayNameResult, response)
}

pub fn (mut client TFGridClient) gateways_get_name(name string) !GatewayNameResult {
	response := client.rpc.call(cmd: 'gateway.name.get', data: name)!

	return json.decode(GatewayNameResult, response)
}

// Delete fqdn using deployment name
pub fn (mut client TFGridClient) gateways_delete_fqdn(name string) ! {
	client.rpc.call(cmd: 'gateway.fqdn.delete', data: name)!
}

pub fn (mut client TFGridClient) gateways_delete_name(name string) ! {
	client.rpc.call(cmd: 'gateway.name.delete', data: name)!
}
