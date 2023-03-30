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

	k8s := deploy_k8s(mut client)!
	println("deploy_result ${k8s}")

	k8s_get := client.k8s_get('testk8s')!
	println("get_result ${k8s_get}")

	client.k8s_delete('testk8s')!
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
		mnemonics: 'mom picnic deliver again rug night rabbit music motion hole lion where'
		network: 'dev'
	}
	client.login(cred)!
}

fn deploy(mut client tfgrid.TFGridClient) !tfgrid.MachinesResult {
	mut disks := []tfgrid.Disk{}
	disks << tfgrid.Disk{
		name: 'disk1'
		size: 10
		mountpoint: '/mnt/disk1'
	}

	mut machines := []tfgrid.Machine{}
	machines << tfgrid.Machine{
		name: 'vm1'
		cpu: 2
		memory: 2048
		rootfs_size: 512
		env_vars: {
			"SSH_KEY": 'ssh-rsa ...'
		}
		disks: disks
	}

	machines_model := tfgrid.MachinesModel{
		name: 'project1'
		network: tfgrid.Network{
			name: 'net1'
			ip_range: '10.20.0.0/16'
			add_wireguard_access: true
			description: 'network'
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
