import freeflowuniverse.crystallib.threefold.tfgrid
import json
import time

fn test_main() ? {
	mut client := tfgrid.new()!

	login(mut client)!

	gateway_fqdn_deploy := deploy_gateway_fqdn(mut client, 'project1')!
	println('gateway fqdn: ${gateway_fqdn_deploy}')
	gateway_name_deploy := deploy_gateway_name(mut client, 'project2')!
	println('gateway name: ${gateway_name_deploy}')
	k8s := deploy_k8s(mut client, 'project3')!
	println('deploy_result ${k8s}')
	deployment_res := deploy(mut client, 'project4')!
	println('deployment result: ${deployment_res}')
	zdb := deploy_zdb(mut client, 'project5')!
	println('deploy_result ${zdb}')

	// this timeout is for graphql database to have all latest updates
	time.sleep(20 * time.second)

	gateway_fqdn_get := get_gateway_fqdn(mut client, 'project1')!
	println('gateway fqdn: ${gateway_fqdn_get}')
	gateway_name_get := get_gateway_name(mut client, 'project2')!
	println('gateway name: ${gateway_name_get}')
	k8s_get := client.k8s_get('project3')!
	println('get_result ${k8s_get}')
	get_dep := get_deployment(mut client, 'project4')!
	println('get deployment: ${get_dep}')
	zdb_get := client.zdb_get('project5')!
	println('get_result ${zdb_get}')

	// delete_project(mut client)!

	// k8s := deploy_k8s(mut client)!
	// println("deploy_result ${k8s}")

	// time.sleep(time.second * 10)
	// k8s_get := client.k8s_get('testk8s')!
	// println("get_result ${k8s_get}")

	// client.k8s_delete('testk8s')!

	// zdb := deploy_zdb(mut client)!
	// println("deploy_result ${zdb}")

	// time.sleep(time.second * 10)
	// zdb_get := client.zdb_get('testzdb')!
	// println("get_result ${zdb_get}")

	// client.zdb_delete('testzdb')!

	// res := client.filter_nodes(tfgrid.FilterOptions{
	// 	// farm_id: 336
	// 	mru: 2048
	// })!
	// println("nodes ${res}")
	delete_gateway_fqdn(mut client, 'project1')!
	delete_gateway_name(mut client, 'project2')!
	client.k8s_delete('project3')!
	delete_project(mut client, 'project4')!
	client.zdb_delete('project5')!
}

fn deploy_zdb(mut client tfgrid.TFGridClient, project_name string) !tfgrid.ZDBResult {
	return client.zdb_deploy(tfgrid.ZDB{
		node_id: 33
		name: project_name
		password: 'strong'
		public: false
		size: 10
		mode: 'user'
	})
}

fn get_gateway_fqdn(mut client tfgrid.TFGridClient, project_name string) !tfgrid.GatewayFQDNResult {
	return client.gateways_get_fqdn(project_name)!
}

fn deploy_gateway_fqdn(mut client tfgrid.TFGridClient, project_name string) !tfgrid.GatewayFQDNResult {
	mut backends := []string{}
	backends << 'http://1.1.1.1:9000'
	gateway_fqdn_model := tfgrid.GatewayFQDN{
		name: project_name
		node_id: 11
		backends: backends
		fqdn: 'hamada1.3x0.me'
	}

	return client.gateways_deploy_fqdn(gateway_fqdn_model)!
}

fn delete_gateway_fqdn(mut client tfgrid.TFGridClient, project_name string) ! {
	client.gateways_delete_fqdn(project_name)!
}

fn get_gateway_name(mut client tfgrid.TFGridClient, project_name string) !tfgrid.GatewayNameResult {
	return client.gateways_get_name(project_name)!
}

fn deploy_gateway_name(mut client tfgrid.TFGridClient, project_name string) !tfgrid.GatewayNameResult {
	mut backends := []string{}
	backends << 'http://1.1.1.1:9000'
	gateway_name_model := tfgrid.GatewayName{
		name: project_name
		node_id: 11
		backends: backends
	}

	return client.gateways_deploy_name(gateway_name_model)!
}

fn delete_gateway_name(mut client tfgrid.TFGridClient, project_name string) ! {
	client.gateways_delete_name(project_name)!
}

fn deploy_k8s(mut client tfgrid.TFGridClient, project_name string) !tfgrid.K8sClusterResult {
	master_node := tfgrid.K8sNode{
		name: "mater",
		// node_id: 11,
		farm_id: 336,
		cpu: 1,
		memory: 2048,
		disk_size: 1
	}

	mut worker_nodes := []tfgrid.K8sNode{}
	worker_nodes << tfgrid.K8sNode{
		name: "w1",
		// node_id: 33,
		cpu: 1,
		memory: 2048,
		disk_size: 50,
		// public_ip: true
	}

	worker_nodes << tfgrid.K8sNode{
		name: "w2",
		// node_id: 33,
		cpu: 1,
		memory: 2048,
		disk_size: 2000,
		// public_ip: true
	}

	worker_nodes << tfgrid.K8sNode{
		name: "w3",
		// node_id: 33,
		cpu: 1,
		memory: 2048,
		disk_size: 50,
		// public_ip: true
	}

	cluster := tfgrid.K8sCluster{
		name: "testk8ss",
		token: "toccccen",
		ssh_key: "...",
		master: master_node,
		workers: worker_nodes
	}

	return client.k8s_deploy(cluster)!
}

fn login(mut client tfgrid.TFGridClient) ! {
	cred := tfgrid.Credentials{
		mnemonics: 'route visual hundred rabbit wet crunch ice castle milk model inherit outside'
		network: 'dev'
	}
	client.login(cred)!
}

fn deploy(mut client tfgrid.TFGridClient, project_name string) !tfgrid.MachinesResult {
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
			'SSH_KEY': 'ssh-rsa ...'
		}
		disks: disks
	}

	machines_model := tfgrid.MachinesModel{
		name: project_name
		network: tfgrid.Network{
			add_wireguard_access: true
		}
		machines: machines
		metadata: 'metadata1'
		description: 'description'
	}
	return client.machines_deploy(machines_model)!
}

fn get_deployment(mut client tfgrid.TFGridClient, project_name string) !tfgrid.MachinesResult {
	return client.machines_get(project_name)!
}

fn delete_project(mut client tfgrid.TFGridClient, project_name string) ! {
	return client.machines_delete(project_name)
}
