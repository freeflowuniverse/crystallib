module twinclient2

import json



fn new_gateways(mut client TwinClient) GateWays {
	// Initialize new stellar.
	return GateWays{
		client: unsafe {client}
	}
}

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut gw GateWays) deploy_fqdn(payload GatewayFQDN) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := gw.client.send('gateway.deploy_fqdn', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut gw GateWays) deploy_name(payload GatewayName) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := gw.client.send('gateway.deploy_name', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get fqdn info using deployment name.
pub fn (mut gw GateWays) get_fqdn(name string) ?[]Deployment {
	response := gw.client.send('gateway.get_fqdn', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Get domain name info using deployment name
pub fn (mut gw GateWays) get_name(name string) ?[]Deployment {
	response := gw.client.send('gateway.get_name', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// Delete fqdn using deployment name
pub fn (mut gw GateWays) delete_fqdn(name string) ?ContractResponse {
	response := gw.client.send('gateway.delete_fqdn', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}

// Delete name domain on gateway using deployment name
pub fn (mut gw GateWays) delete_name(name string) ?ContractResponse {
	response := gw.client.send('gateway.delete_name', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}
