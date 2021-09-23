import twinclient { Disk, Env, GenericMachine, Network, init }

const redis_server = 'localhost:6379'

pub fn test_generic_machine() {
	mut twin_dest := 49 // ADD TWIN ID.
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Deploy a generic machine
	payload := GenericMachine{
		node_id: 2
		public_ip: false
		cpu: u32(1)
		memory: u64(1024)
		name: 'essam'
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		entrypoint: '/sbin/zinit init'
		disks: [Disk{
			name: 'essamdisk'
			size: 10
			mountpoint: '/'
		}]
		network: Network{
			ip_range: '10.200.0.0/16'
			name: 'essamnet'
		}
		env: Env{
			ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
		}
	}

	// Create new generic machine
	new_machine := tw.deploy_machine(payload) or { panic(err) }
	println('--------- Deploy Machine ---------')
	println(new_machine)

	// Get Deployed Machine
	get_machine := tw.get_machine(payload.name) or { panic(err) }
	println('--------- Get Machine ---------')
	println(get_machine)

	// List Deployed Machines
	all_my_machines := tw.list_machines() or { panic(err) }
	assert payload.name in all_my_machines
	println('--------- List Deployed Machines for Each User ---------')
	println(all_my_machines)

	// Delete Deployed Machine
	delete_machine := tw.delete_machine('essam') or { panic(err) }
	println('--------- Delete Machine ---------')
	println(delete_machine)
}
