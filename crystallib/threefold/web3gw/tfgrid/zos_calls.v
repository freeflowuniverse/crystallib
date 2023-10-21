module tfgrid


pub fn (mut t TFGridClient) zos_node_statistics(request ZOSNodeRequest) !NodeStatistics {
	return t.client.send_json_rpc[[]ZOSNodeRequest, NodeStatistics]('tfgrid.ZOSStatisticsGet',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_network_list_wg_ports(request ZOSNodeRequest) ![]u16 {
	return t.client.send_json_rpc[[]ZOSNodeRequest, []u16]('tfgrid.ZOSNetworkListWGPorts',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_network_interfaces(request ZOSNodeRequest) !map[string][]u32 {
	return t.client.send_json_rpc[[]ZOSNodeRequest, map[string][]u32]('tfgrid.ZOSNetworkInterfaces',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_network_public_config(request ZOSNodeRequest) !PublicConfig {
	return t.client.send_json_rpc[[]ZOSNodeRequest, PublicConfig]('tfgrid.ZOSNetworkPublicConfigGet',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_system_dmi(request ZOSNodeRequest) !SystemDMI {
	return t.client.send_json_rpc[[]ZOSNodeRequest, SystemDMI]('tfgrid.ZOSSystemDMI',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_system_hypervisor(request ZOSNodeRequest) !string {
	return t.client.send_json_rpc[[]ZOSNodeRequest, string]('tfgrid.ZOSSystemHypervisor',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_system_version(request ZOSNodeRequest) !ZOSVersion {
	return t.client.send_json_rpc[[]ZOSNodeRequest, ZOSVersion]('tfgrid.ZOSSystemVersion',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_deployment_deploy(request ZOSNodeRequest) ! {
	t.client.send_json_rpc[[]ZOSNodeRequest, string]('tfgrid.ZOSDeploymentDeploy', [
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_deployment_update(request ZOSNodeRequest) ! {
	t.client.send_json_rpc[[]ZOSNodeRequest, string]('tfgrid.ZOSDeploymentUpdate', [
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_deployment_changes(request ZOSNodeRequest) !Workload {
	return t.client.send_json_rpc[[]ZOSNodeRequest, Workload]('tfgrid.ZOSDeploymentChanges',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_deployment_get(request ZOSNodeRequest) !Deployment {
	return t.client.send_json_rpc[[]ZOSNodeRequest, Deployment]('tfgrid.ZOSDeploymentGet',
		[
		request,
	], t.timeout)!
}

pub fn (mut t TFGridClient) zos_deployment_delete(request ZOSNodeRequest) ! {
	t.client.send_json_rpc[[]ZOSNodeRequest, string]('tfgrid.ZOSDeploymentDelete', [
		request,
	], t.timeout)!
}
