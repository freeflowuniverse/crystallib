module twinclient2

import json

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut tw TwinClient) deploy_gateway_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('gateway.deploy_fqdn', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut tw TwinClient) deploy_gateway_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('gateway.deploy_name', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Get fqdn info using deployment name.
pub fn (mut tw TwinClient) get_gateway_fqdn(name string) ?[]Deployment {
	response := tw.send('gateway.get_fqdn', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// Get domain name info using deployment name
pub fn (mut tw TwinClient) get_gateway_name(name string) ?[]Deployment {
	response := tw.send('gateway.get_name', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// Delete fqdn using deployment name
pub fn (mut tw TwinClient) delete_gateway_fqdn(name string) ?ContractResponse {
	response := tw.send('gateway.delete_fqdn', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}

// Delete name domain on gateway using deployment name
pub fn (mut tw TwinClient) delete_gateway_name(name string) ?ContractResponse {
	response := tw.send('gateway.delete_name', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}
