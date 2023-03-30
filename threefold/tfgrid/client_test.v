import freeflowuniverse.crystallib.threefold.tfgrid

import time

fn test_main() ? {
	mut client := tfgrid.new()!
	
	// login(mut client)!

	// // gateway fqdn
	// gateway_fqdn_deploy := deploy_gateway_fqdn(mut client)!
	// println('gateway fqdn: ${gateway_fqdn_deploy}')

	// // sleep to let graphql database see changes
	// time.sleep(time.second * 20)

	// gateway_fqdn_get := get_gateway_fqdn(mut client)!
	// println('gateway fqdn: ${gateway_fqdn_get}')

	// delete_gateway_fqdn(mut client)!


	// // gateway name
	// gateway_name_deploy := deploy_gateway_name(mut client)!
	// println('gateway name: ${gateway_name_deploy}')

	// time.sleep(time.second * 20)

	// gateway_name_get := get_gateway_name(mut client)!
	// println('gateway name: ${gateway_name_get}')

	delete_gateway_name(mut client)!

	// machine model
	deployment_res := deploy(mut client)!
	println('deployment result: ${deployment_res}')

	time.sleep(time.second * 20)

	get_dep := get_deployment(mut client)!
	println('get deployment: ${get_dep}')

	delete_project(mut client)!

	// k8s cluster
	k8s := deploy_k8s(mut client)!
	println("deploy_result ${k8s}")

	time.sleep(time.second * 20)
	k8s_get := client.k8s_get('testk8s')!
	println("get_result ${k8s_get}")

	client.k8s_delete('testk8s')!

	// zdb 
	zdb := deploy_zdb(mut client)!
	println("deploy_result ${zdb}")

	time.sleep(time.second * 20)
	zdb_get := client.zdb_get('testzdb')!
	println("get_result ${zdb_get}")

	client.zdb_delete('testzdb')!
}

fn deploy_zdb(mut client tfgrid.TFGridClient) !tfgrid.ZDBResult {
	return client.zdb_deploy(tfgrid.ZDB{
		node_id: 33
		name: 'testzdb'
		password: 'strong'
		public: false
		size: 10
		mode: 'user'
	})
}

fn get_gateway_fqdn(mut client tfgrid.TFGridClient) !tfgrid.GatewayFQDNResult{
	return client.gateways_get_fqdn('hamadaaaafqdn')!
}

fn deploy_gateway_fqdn(mut client tfgrid.TFGridClient) !tfgrid.GatewayFQDNResult{
	mut backends := []string{}
	backends << 'http://1.1.1.1:9000'
	gateway_fqdn_model := tfgrid.GatewayFQDN{
		name: "hamadaaaafqdn",
		node_id: 11,
		backends: backends
		fqdn: 'hamada1.3x0.me'
	}

	return client.gateways_deploy_fqdn(gateway_fqdn_model)!
}

fn delete_gateway_fqdn(mut client tfgrid.TFGridClient) !{
	client.gateways_delete_fqdn('hamadaaaafqdn')!
}

fn get_gateway_name(mut client tfgrid.TFGridClient) !tfgrid.GatewayNameResult{
	return client.gateways_get_name('hamadaaaa')!
}

fn deploy_gateway_name(mut client tfgrid.TFGridClient) !tfgrid.GatewayNameResult{
	mut backends := []string{}
	backends << 'http://1.1.1.1:9000'
	gateway_name_model := tfgrid.GatewayName{
		name: "hamadaaaa",
		node_id: 11,
		backends: backends
	}

	return client.gateways_deploy_name(gateway_name_model)!
}

fn delete_gateway_name(mut client tfgrid.TFGridClient) !{
	client.gateways_delete_name('hamadaaaa')!
}

fn deploy_k8s(mut client tfgrid.TFGridClient) !tfgrid.K8sClusterResult {
	master_node := tfgrid.K8sNode{
		name: "mater",
		node_id: 11,
		cpu: 1,
		memory: 2048,
		disk_size: 1
	}

	mut worker_nodes := []tfgrid.K8sNode{}
	worker_nodes << tfgrid.K8sNode{
		name: "w1",
		node_id: 33,
		cpu: 1,
		memory: 2048,
		disk_size: 1
	}

	cluster := tfgrid.K8sCluster{
		name: "testk8s",
		token: "toccccen",
		ssh_key: "...",
		master: master_node,
		workers: worker_nodes
	}

	return client.k8s_deploy(cluster) !
}

fn login(mut client tfgrid.TFGridClient) ! {
	cred := tfgrid.Credentials{
		mnemonics: 'route visual hundred rabbit wet crunch ice castle milk model inherit outside'
		network: 'dev'
	}
	client.login(cred)!
}

fn deploy(mut client tfgrid.TFGridClient) !tfgrid.MachinesResult {
	mut disks := []tfgrid.Disk{}
	disks << tfgrid.Disk{
		size: 10
		mountpoint: '/mnt/disk1'
	}

	mut machines := []tfgrid.Machine{}
	machines << tfgrid.Machine{
		name: 'vm1'
		node_id: 33
		cpu: 2
		memory: 2048
		rootfs_size: 1024
		env_vars: {
			"SSH_KEY": 'ssh-rsa ...'
		}
		disks: disks
	}

	machines_model := tfgrid.MachinesModel{
		name: 'project1'
		network: tfgrid.Network{
			add_wireguard_access: true
		}
		machines: machines
		metadata: 'metadata1'
		description: 'description'
	}
	return client.machines_deploy(machines_model)!
}

fn get_deployment(mut client tfgrid.TFGridClient) !tfgrid.MachinesResult {
	return client.machines_get('project1')!
}

fn delete_project(mut client tfgrid.TFGridClient) ! {
	return client.machines_delete('project1')
}
