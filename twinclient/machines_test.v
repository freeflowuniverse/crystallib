module twinclient

struct MachinesTestData {
mut:
	payload        Machines
	update_payload Machines
	new_machine    AddMachine
}

pub fn setup_machines_test() (Client, MachinesTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_kubernetes_test with error: $err')
	}

	mut data := MachinesTestData{
		payload: Machines{
			name: 'essamMachines'
			network: Network{
				ip_range: '10.200.0.0/16'
				name: 'essamnet'
			}
			machines: [
				Machine{
					name: 'm1'
					node_id: 2
					public_ip: false
					planetary: true
					cpu: 1
					memory: 1024
					rootfs_size: 10
					flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
					entrypoint: '/sbin/zinit init'
					env: Env{
						ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
					}
				},
			]
		}
	}
	data.update_payload = Machines{
		...data.payload
		metadata: 'Machines'
	}

	data.new_machine = AddMachine{
		deployment_name: data.payload.name
		name: 'm2'
		node_id: 3
		public_ip: false
		planetary: true
		cpu: 1
		memory: 1024
		rootfs_size: 10
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		entrypoint: '/sbin/zinit init'
		env: Env{
			ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
		}
	}
	return client, data
}

pub fn test_deploy_machines() {
	// redis_server and twin_dest are const in client.v
	mut client, data := setup_machines_test()

	println('--------- Deploy Machines ---------')
	machines := client.deploy_machines(data.payload) or { panic(err) }
	println(machines)
}

pub fn test_list_mahcines() {
	mut client, data := setup_machines_test()

	println('--------- List Deployed Machines ---------')
	all_my_machines := client.list_machines() or { panic(err) }
	assert data.payload.name in all_my_machines
	println(all_my_machines)
}

pub fn test_get_machines() {
	mut client, data := setup_machines_test()

	println('--------- Get Machines ---------')
	get_machines := client.get_machines(data.payload.name) or { panic(err) }
	println(get_machines)
}

// pub fn test_update_machines() {
// 	mut client, data := setup_machines_test()

// 	println('--------- Update Machines ---------')
// 	update_machines := client.update_machines(data.update_payload) or { panic(err) }
// 	println(update_machines)
// }

pub fn test_add_machine() {
	mut client, data := setup_machines_test()

	println('--------- Add Machine ---------')
	add_machine := client.add_machine(data.new_machine) or { panic(err) }
	println(add_machine)
}

pub fn test_delete_machine() {
	mut client, data := setup_machines_test()

	println('--------- Delete Machine ---------')
	delete_machine := client.delete_machine(
		name: data.new_machine.name
		deployment_name: data.payload.name
	) or { panic(err) }
	println(delete_machine)
}

pub fn test_delete_machines() {
	mut client, data := setup_machines_test()

	println('--------- Delete Machines ---------')
	delete_machine := client.delete_machines(data.payload.name) or { panic(err) }
	println(delete_machine)
}
