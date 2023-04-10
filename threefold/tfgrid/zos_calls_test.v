module tfgrid

import freeflowuniverse.crystallib.threefold.tfgrid
import json

fn test_main() {
	mut client := tfgrid.new()!

	login(mut client)!

	// ZOS calls

	// zos_deploy(mut client)!

	version := zos_system_version(mut client)!
	println('system version: ${version}')

	hypervisor := zos_system_hypervisor(mut client)!
	println('hypervisor: ${hypervisor}')

	dmi := zos_system_dmi(mut client)!
	println('dmi: ${dmi}')

	cfg := zos_network_public_config(mut client)!
	println('public config: ${cfg}')

	interfaces := zos_network_interfaces(mut client)!
	println('network interfacs: ${interfaces}')

	stats := zos_node_statistics(mut client)!
	println('statistics: ${stats}')

	changes := zos_deployment_changes(mut client)!
	println('changes: ${changes}')

	// zos_deployment_update(mut client)!

	// zos_deployment_delete(mut client)!

	deployment_get := zos_deployment_get(mut client)!
	println('get deployment: ${deployment_get}')
}

fn login(mut client tfgrid.TFGridClient) ! {
	cred := tfgrid.Credentials{
		mnemonics: 'route visual hundred rabbit wet crunch ice castle milk model inherit outside'
		network: 'dev'
	}
	client.login(cred)!
}

fn zos_deployment_get(mut client tfgrid.TFGridClient) !tfgrid.Deployment {
	return client.zos_deployment_get(29, 22226)
}

fn zos_deployment_delete(mut client tfgrid.TFGridClient) ! {
	return client.zos_deployment_delete(33, 1234)
}

fn zos_deployment_update(mut client tfgrid.TFGridClient) ! {
	mut wls := []tfgrid.Workload{}
	wls << tfgrid.Workload{
		version: 0
		name: 'wl1'
		workload_type: 'typ1'
		data: 'hamada_data'
		metadata: 'hamada_meta'
		description: 'hamada_res'
		result: tfgrid.Result{
			created: 123345
			state: 'ok'
			error: 'err1'
			data: 'datadatadata'
		}
	}
	mut sig_requests := []tfgrid.SignatureRequest{}
	sig_requests << tfgrid.SignatureRequest{
		twin_id: 1
		required: true
		weight: 1
	}
	dl := tfgrid.Deployment{
		version: 0
		contract_id: 22226
		twin_id: 49
		metadata: 'hamada_meta'
		description: 'hamada_desc'
		expiration: 1234
		signature_requirement: tfgrid.SignatureRequirement{
			weight_required: 1
			requests: sig_requests
		}
		workloads: wls
	}

	return client.zos_deployment_update(29, dl)
}

fn zos_deployment_changes(mut client tfgrid.TFGridClient) ![]tfgrid.Workload {
	return client.zos_deployment_changes(29, 22226)
}

fn zos_node_statistics(mut client tfgrid.TFGridClient) !tfgrid.Statistics {
	return client.zos_node_statistics(34)
}

fn zos_network_list_wg_ports(mut client tfgrid.TFGridClient) ![]u16 {
	return client.zos_network_list_wg_ports(11)
}

fn zos_network_interfaces(mut client tfgrid.TFGridClient) !map[string][]string {
	return client.zos_network_interfaces(11)
}

fn zos_network_public_config(mut client tfgrid.TFGridClient) !tfgrid.PublicConfig {
	return client.zos_network_public_config(11)
}

fn zos_system_dmi(mut client tfgrid.TFGridClient) !tfgrid.DMI {
	return client.zos_system_dmi(33)
}

fn zos_system_hypervisor(mut client tfgrid.TFGridClient) !string {
	return client.zos_system_hypervisor(33)
}

fn zos_system_version(mut client tfgrid.TFGridClient) !tfgrid.SystemVersion {
	return client.zos_system_version(33)
}

fn zos_deploy(mut client tfgrid.TFGridClient) ! {
	mut wls := []tfgrid.Workload{}
	wls << tfgrid.Workload{
		version: 0
		name: 'wl1'
		workload_type: 'typ1'
		data: 'hamada_data'
		metadata: 'hamada_meta'
		description: 'hamada_res'
		result: tfgrid.Result{
			created: 123345
			state: 'ok'
			error: 'err1'
			data: 'datadatadata'
		}
	}
	mut sig_requests := []tfgrid.SignatureRequest{}
	sig_requests << tfgrid.SignatureRequest{
		twin_id: 1
		required: true
		weight: 1
	}
	dl := tfgrid.Deployment{
		version: 0
		twin_id: 1
		metadata: 'hamada_meta'
		description: 'hamada_desc'
		expiration: 1234
		signature_requirement: tfgrid.SignatureRequirement{
			weight_required: 1
			requests: sig_requests
		}
		workloads: wls
	}
	return client.zos_deployment_deploy(234, dl)
}
