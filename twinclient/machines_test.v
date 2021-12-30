module twinclient

import os.cmdline
import os

struct MachinesTestData {
mut:
	payload        Machines
	update_payload Machines
	new_machine    AddMachine
}

fn setup_machines_test() (Client, MachinesTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_machines_test with error: $err')
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
		node_id: 4
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

fn t0_deploy_machines(mut client Client, data MachinesTestData) {
	println('--------- Deploy Machines ---------')
	machines := client.deploy_machines(data.payload) or { panic(err) }
	println(machines)
}

fn t1_list_machines(mut client Client, data MachinesTestData) {
	println('--------- List Deployed Machines ---------')
	all_my_machines := client.list_machines() or { panic(err) }
	assert data.payload.name in all_my_machines
	println(all_my_machines)
}

fn t2_get_machines(mut client Client, data MachinesTestData) {
	println('--------- Get Machines ---------')
	get_machines := client.get_machines(data.payload.name) or { panic(err) }
	println(get_machines)
}

fn t3_update_machines(mut client Client, data MachinesTestData) {
	println('--------- Update Machines ---------')
	update_machines := client.update_machines(data.update_payload) or { panic(err) }
	println(update_machines)
}

fn t4_add_machine(mut client Client, data MachinesTestData) {
	println('--------- Add Machine ---------')
	add_machine := client.add_machine(data.new_machine) or { panic(err) }
	println(add_machine)
}

fn t5_delete_machine(mut client Client, data MachinesTestData) {
	println('--------- Delete Machine ---------')
	delete_machine := client.delete_machine(
		name: data.new_machine.name
		deployment_name: data.payload.name
	) or { panic(err) }
	println(delete_machine)
}

fn t6_delete_machines(mut client Client, data MachinesTestData) {
	println('--------- Delete Machines ---------')
	delete_machine := client.delete_machines(data.payload.name) or { panic(err) }
	println(delete_machine)
}

pub fn test_machines() {
	mut client, data := setup_machines_test()
	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_deploy_machines', 't1_list_machines', 't2_get_machines', 't3_update_machines',
		't4_add_machine', 't5_delete_machine', 't6_delete_machines']

	for tc in cmd_test {
		match tc {
			't0_deploy_machines' {
				t0_deploy_machines(mut client, data)
			}
			't1_list_machines' {
				t1_list_machines(mut client, data)
			}
			't2_get_machines' {
				t2_get_machines(mut client, data)
			}
			't3_update_machines' {
				t3_update_machines(mut client, data)
			}
			't4_add_machine' {
				t4_add_machine(mut client, data)
			}
			't5_delete_machine' {
				t5_delete_machine(mut client, data)
			}
			't6_delete_machines' {
				t6_delete_machines(mut client, data)
			}
			'all' {
				t0_deploy_machines(mut client, data)
				t1_list_machines(mut client, data)
				t2_get_machines(mut client, data)
				t3_update_machines(mut client, data)
				t4_add_machine(mut client, data)
				t5_delete_machine(mut client, data)
				t6_delete_machines(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
