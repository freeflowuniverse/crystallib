import twinclient { K8S, Network, Node, init }

const redis_server = 'localhost:6379'

pub fn test_generic_machine() {
	mut twin_dest := 49 // ADD TWIN ID.
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Deploy a kubernetes
	payload := K8S{
		name: 'essamkube'
		secret: 'essam1234'
		network: Network{
			ip_range: '10.201.0.0/16'
			name: 'essamkubenet'
		}
		masters: [Node{
			name: 'master1'
			node_id: 3
			cpu: 1
			memory: 1024
			disk_size: 15
			public_ip: false
		}]
		workers: [Node{
			name: 'worker1'
			node_id: 2
			cpu: 1
			memory: 1024
			disk_size: 15
			public_ip: false
		}]
		description: 'This is trial from V client to deploy kubernetes'
		ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
	}
	// Create new kubernetes
	new_kube := tw.deploy_kubernetes(payload) or { panic(err) }
	println('--------- Deploy K8S ---------')
	println(new_kube)

	// Get Deployed kubernetes
	get_kube := tw.get_kubernetes(payload.name) or { panic(err) }
	println('--------- Get K8S ---------')
	println(get_kube)

	// Add Worker
	add_worker_instance := Node{
			name: 'worker2'
			node_id: 2
			cpu: 1
			memory: 1024
			disk_size: 15
			public_ip: false
		}
	add_worker_result := tw.add_worker(payload.name, add_worker_instance) or { panic(err) }
	println('--------- Add Worker ---------')
	println(add_worker_result)

	// Delete Worker
	delete_worker_name := add_worker_instance.name
	delete_worker_result := tw.delete_worker(payload.name, delete_worker_name) or { panic(err) }
	println('--------- Delete Worker ---------')
	println(delete_worker_result)

	// List Deployed kubernetes
	all_my_kubes := tw.list_kubernetes() or { panic(err) }
	assert payload.name in all_my_kubes
	println('--------- List Deployed K8S for Each User ---------')
	println(all_my_kubes)
	
	// Delete Deployed kubernetes
	delete_kube := tw.delete_kubernetes(payload.name) or { panic(err) }
	println('--------- Delete K8S ---------')
	println(delete_kube)
}
