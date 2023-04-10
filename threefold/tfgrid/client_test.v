import freeflowuniverse.crystallib.threefold.tfgrid

// import time

fn test_main() ? {
	mut client := tfgrid.new()!
	
	login(mut client)!

	// deployment_res := deploy(mut client)!
	// println('deployment result: ${deployment_res}')

	// // sleep 10 seconds to let graphql database see changes
	// time.sleep(time.second * 10)

	// get_dep := get_deployment(mut client)!
	// println('get deployment: ${get_dep}')

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

fn deploy_k8s(mut client tfgrid.TFGridClient) !tfgrid.K8sClusterResult {
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

	return client.k8s_deploy(cluster) !
}

fn login(mut client tfgrid.TFGridClient) ! {
	cred := tfgrid.Credentials{
		mnemonics: 'mom picnic deliver again rug night rabbit music motion hole lion where'
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
