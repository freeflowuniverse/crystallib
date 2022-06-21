import twinclient

struct KubernetesTestData {
mut:
	payload        twinclient.K8S
	update_payload twinclient.K8S
	new_worker     twinclient.AddKubernetesNode
}

fn setup_kubernetes_test() (twinclient.Client, KubernetesTestData) {
	redis_server := 'localhost:6379'
	twin_id := 133
	mut client := twinclient.init(redis_server, twin_id) or {
		panic('Fail in setup_kubernetes_test with error: $err')
	}

	mut data := KubernetesTestData{
		payload: twinclient.K8S{
			name: 'testkubs1'
			secret: 'testtest'
			network: twinclient.Network{
				ip_range: '10.201.0.0/16'
				name: 'testnetkub'
			}
			masters: [
				twinclient.KubernetesNode{
					name: 'master1'
					node_id: 3
					cpu: 1
					memory: 1024
					rootfs_size: 10
					disk_size: 15
					public_ip: false
					planetary: true
				},
			]
			description: 'This is trial from V client to deploy kubernetes'
			ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
		}
	}
	data.update_payload = twinclient.K8S{
		...data.payload
		metadata: 'kubernetes'
	}
	data.new_worker = twinclient.AddKubernetesNode{
		deployment_name: data.payload.name
		name: 'worker1'
		node_id: 2
		cpu: 1
		memory: 1024
		rootfs_size: 10
		disk_size: 15
		public_ip: false
		planetary: true
	}

	return client, data
}


pub fn test_deploy_k8s() {
	mut client, data := setup_kubernetes_test()

	println('------------- Deploy k8s -------------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	defer {
		delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	}

	assert new_kube.contracts.created.len == 1
	assert new_kube.contracts.updated.len == 0
	assert new_kube.contracts.deleted.len == 0
}

pub fn test_list_k8s() {
	mut client, data := setup_kubernetes_test()

	println('------------- Deploy k8s -------------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	defer {
		delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	}

	all_my_kubes := client.list_kubernetes() or { panic(err) }
	assert data.payload.name in all_my_kubes
}

pub fn test_update_k8s() {
	mut client, data := setup_kubernetes_test()

	println('------------- Deploy k8s -------------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	defer {
		delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	}

	kube := client.update_kubernetes(data.update_payload)
	assert kube.contracts.created.len == 0
	assert kube.contracts.updated.len == 1
	assert kube.contracts.deleted.len == 0
}

pub fn test_add_worker() {
	mut client, data := setup_kubernetes_test()

	println('------------- Deploy k8s -------------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	defer {
		delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	}

	add_worker_result := client.add_worker(data.new_worker) or { panic(err) }
	assert add_worker_result.workers.len == 2
}

pub fn test_delete_worker() {
	mut client, data := setup_kubernetes_test()

	println('------------- Deploy k8s -------------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	defer {
		delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	}

	add_worker_result := client.add_worker(data.new_worker) or { panic(err) }
	assert add_worker_result.workers.len == 2

	delete_worker_result := client.delete_worker(
		name: data.new_worker.name
		deployment_name: data.payload.name
	) or { panic(err) }
	assert delete_worker_result.workers.len == 1
}
