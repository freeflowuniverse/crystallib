
import twinclient

pub struct MachinesTestData {
pub mut:
	payload        twinclient.Machines
	update_payload twinclient.Machines
	new_machine    twinclient.AddMachine
}

pub fn setup_machines_test() (twinclient.Client, MachinesTestData) {
	redis_server := 'localhost:6379'
	twin_id := 133
	mut client := twinclient.init(redis_server, twin_id) or {
		panic('Fail in setup_machines_test with error: $err')
	}

	mut data := MachinesTestData{
		payload: twinclient.Machines{
			name: 'testvmm'
			network: twinclient.Network{
				ip_range: '10.200.0.0/16'
				name: 'testing'
			}
			machines: [
				twinclient.Machine{
					name: 'm1'
					node_id: 18
					public_ip: false
					planetary: true
					cpu: 1
					memory: 1024
					rootfs_size: 0
					flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
					entrypoint: '/sbin/zinit init'
					env: twinclient.Env{
						ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVaulbZarLfnE/9flAtT85cezs46qDdgaCHdliQRST16WrJ6jukZvTpWjUo0K/v+UHmxCnkY4KLv3Yl1cWSUFdlSTe21hoK7xEyU9F21PbhzKQASQga/J4QUxyZpdMybzt9ndlFsOy7x0xNUSMljf38za2yHGcpKGRw1Ungd4PBWKv0sKTKYjhHoHCTa72NAc95EMFJpvfowVWJvsxgjcHjOSaQpRQiXb3eHfMj5I4h7yhJOFin7GVev6bSwPEJRN+ydGiCmv3paNGvJbFEOROIBAp6q78RDf4rNyf3Vr244yB8ffl6bKpPb4LA0Ntex+e7jaxzBWAboiWXxDEadG2P/RAfciXasICZXLcZTfjlbXJ1OHTe/aStEgy36IWvt/SwKcazG/2V0enc3UwE/SzeqGyPT9A8HhuMn9TB4cYOTh9146Gl63EtTBnFX3z5EqQwytFyyxXToqDOuJAMYB2gKHsB1ePhWZOLxiguOPlU3ZSHm9XI+wZEcBNJ6B2yOM= hassan@hassan-Inspiron-3576'
					}
				},
			]
		}
	}
	data.update_payload = twinclient.Machines{
		...data.payload
		metadata: 'Machines'
	}

	data.new_machine = twinclient.AddMachine{
		deployment_name: "testdep"
		name: 'm2'
		node_id: 4
		public_ip: false
		planetary: true
		cpu: 1
		memory: 1024
		rootfs_size: 10
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		entrypoint: '/sbin/zinit init'
		env: twinclient.Env{
			ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVaulbZarLfnE/9flAtT85cezs46qDdgaCHdliQRST16WrJ6jukZvTpWjUo0K/v+UHmxCnkY4KLv3Yl1cWSUFdlSTe21hoK7xEyU9F21PbhzKQASQga/J4QUxyZpdMybzt9ndlFsOy7x0xNUSMljf38za2yHGcpKGRw1Ungd4PBWKv0sKTKYjhHoHCTa72NAc95EMFJpvfowVWJvsxgjcHjOSaQpRQiXb3eHfMj5I4h7yhJOFin7GVev6bSwPEJRN+ydGiCmv3paNGvJbFEOROIBAp6q78RDf4rNyf3Vr244yB8ffl6bKpPb4LA0Ntex+e7jaxzBWAboiWXxDEadG2P/RAfciXasICZXLcZTfjlbXJ1OHTe/aStEgy36IWvt/SwKcazG/2V0enc3UwE/SzeqGyPT9A8HhuMn9TB4cYOTh9146Gl63EtTBnFX3z5EqQwytFyyxXToqDOuJAMYB2gKHsB1ePhWZOLxiguOPlU3ZSHm9XI+wZEcBNJ6B2yOM= hassan@hassan-Inspiron-3576'
		}
	}
	return client, data
}


pub fn test_deploy_vm() {
	mut client, data := setup_machines_test()

	println('------------- Deploy VM -------------')
	machines := client.deploy_machines(data.payload) or { panic(err) }
	defer {
		client.delete_machines(data.payload.name) or { panic(err) }
	}

	assert machines.contracts.created.len == 1
	assert machines.contracts.updated.len == 0
	assert machines.contracts.deleted.len == 0
}

pub fn test_list_vm() {
	mut client, data := setup_machines_test()

	println('------------- Deploy VM -------------')
	machines := client.deploy_machines(data.payload) or { panic(err) }
	defer {
		client.delete_machines(data.payload.name) or { panic(err) }
	}

	all_my_machines := client.list_machines() or { panic(err) }
	assert data.payload.name in all_my_machines
}

pub fn test_update_vm() {
	mut client, data := setup_machines_test()

	println('------------- Deploy VM -------------')
	machines := client.deploy_machines(data.payload) or { panic(err) }
	defer {
		client.delete_machines(data.payload.name) or { panic(err) }
	}

	update_machines := client.update_machines(data.update_payload) or { panic(err) }
	assert machines.contracts.created.len == 0
	assert machines.contracts.updated.len == 1
	assert machines.contracts.deleted.len == 0
}
