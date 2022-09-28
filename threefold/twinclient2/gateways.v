module twinclient2

import json

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut client TwinClient) gateways_deploy_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('gateway.deploy_fqdn', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

pub fn (mut client TwinClient) gateways_list()?{
	client.send('gateway.list', "{}")?
}

// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut client TwinClient) gateways_deploy_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('gateway.deploy_name', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get fqdn info using deployment name.
pub fn (mut client TwinClient) gateways_get_fqdn(name string) ?[]Deployment {
	response := client.send('gateway.get_fqdn', json.encode({
		'name': name
	}))?

	return json.decode([]Deployment, response.data)
}

// Get domain name info using deployment name
pub fn (mut client TwinClient) gateways_get_name(name string) ?[]Deployment {
	response := client.send('gateway.get_name', json.encode({
		'name': name
	}))?

	return json.decode([]Deployment, response.data)
}

// Delete fqdn using deployment name
pub fn (mut client TwinClient) gateways_delete_fqdn(name string) ?ContractResponse {
	response := client.send('gateway.delete_fqdn', json.encode({
		'name': name
	}))?

	return json.decode(ContractResponse, response.data)
}

// Delete name domain on gateway using deployment name
pub fn (mut client TwinClient) gateways_delete_name(name string) ?ContractResponse {
	response := client.send('gateway.delete_name', json.encode({
		'name': name
	}))?

	return json.decode(ContractResponse, response.data)
}
