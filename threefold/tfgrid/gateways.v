module tfgrid

// Deploy a fully qualified domain on gateway ex: site.com
pub fn (mut client TFGridClient) gateways_deploy_fqdn(payload GatewayFQDN) !GatewayFQDNResult {
	retqueue := client.rpc.call[GatewayFQDN]('tfgrid.gateway.fqdn.deploy', payload)!
	return client.rpc.result[GatewayFQDNResult](500000, retqueue)!
}

// Get fqdn info using deployment name.
pub fn (mut client TFGridClient) gateways_get_fqdn(name string) !GatewayFQDNResult {
	retqueue := client.rpc.call[string]('tfgrid.gateway.fqdn.get', name)!
	return client.rpc.result[GatewayFQDNResult](500000, retqueue)!
}

// Deploy name domain on gateway ex: name.gateway.com
pub fn (mut client TFGridClient) gateways_deploy_name(payload GatewayName) !GatewayNameResult {
	retqueue := client.rpc.call[GatewayName]('tfgrid.gateway.name.deploy', payload)!
	return client.rpc.result[GatewayNameResult](500000, retqueue)!
}

pub fn (mut client TFGridClient) gateways_get_name(name string) !GatewayNameResult {
	retqueue := client.rpc.call[string]('tfgrid.gateway.name.get', name)!
	return client.rpc.result[GatewayNameResult](500000, retqueue)!
}

// Delete fqdn using deployment name
pub fn (mut client TFGridClient) gateways_delete_fqdn(name string) ! {
	retqueue := client.rpc.call[string]('tfgrid.gateway.fqdn.delete', name)!
	client.rpc.result[string](500000, retqueue)!
}

pub fn (mut client TFGridClient) gateways_delete_name(name string) ! {
	retqueue := client.rpc.call[string]('tfgrid.gateway.name.delete', name)!
	client.rpc.result[string](500000, retqueue)!
}
