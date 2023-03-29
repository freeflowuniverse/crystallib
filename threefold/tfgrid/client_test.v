import freeflowuniverse.crystallib.threefold.tfgrid

import time

fn test_main() ? {
	mut client := tfgrid.new()!
	
	login(mut client)!

	deployment_res := deploy(mut client)!
	println('deployment result: ${deployment_res}')

	// sleep 10 seconds to let graphql database see changes
	time.sleep(time.second * 10)

	get_dep := get_deployment(mut client)!
	println('get deployment: ${get_dep}')

	delete_project(mut client)!
}


fn login(mut client tfgrid.TFGridClient) ! {
	cred := tfgrid.Credentials{
		mnemonics: 'PUT YOUR MNEMONICS HERE'
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
