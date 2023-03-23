import freeflowuniverse.crystallib.threefold.tfgrid
import freeflowuniverse.crystallib.redisclient
import json
import time

fn test_main() ? {
	// provide tf-grid client binary path here
	mut client := tfgrid.new('/usr/local/bin/tf-grid')!
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
	mut machines := []tfgrid.Machine{}
	machines << tfgrid.Machine{
		name: 'vm1'
		planetary: true
		cpu: 2
		memory: 2048
		rootfs_size: 512
		ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs+AFNbOtMtWElFISu1NLke5dH3x+HKJ1Ef6qYpMzZlF9UfzKhcTSy+LQTxvk55dABBirsln03rRdsblmyCgJAPq/w75QVRJCoh8Ge47eOmvaIx6MLFKTVHbfdUTaqFUZ9B6OxnufPc/T/4uWuBHXGZHNu+6DFS6nx7d0hQJtke4fetEzu+6LjIup0V9Qvt2xSK7kTTuDqHbXzvqc8J9PWmhTr0Q5N3qNJ2g8RrTO3Whmb7Pr0qMA4gWuBPEQoDHnb0YuXqxd3L94bqf2dqo8zo1dVwAESe9OCjwFzSw/1XyPoHPzMxN5B1Uu0hgwGlUagRnDg/C/kA6RJBht91Q/fXDWdB/sLVMfGKZ8EiybRynMQcQMVGebVOw5dQyK5Jt069spBmlqZzJZ4Zpa6ktxwFW2foJxObVhm5fmFr6c7PYIyT03OkY83V9DJVFR+HiVi5in+0DOujMDoyQYV/6Zyvs1uMeJHARJTjvEYz6dbYcA7odp3Zi4Tmv+d+3nkx+k= superluigi@luigi'
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

fn get_deployment(mut client tfgrid.TFGridClient) ![]tfgrid.Deployment {
	return client.machines_get('project1')!
}

fn delete_project(mut client tfgrid.TFGridClient) ! {
	return client.machines_delete('project1')
}
