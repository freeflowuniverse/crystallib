import twinclient

struct ZDBsTestData {
mut:
	payload        twinclient.ZDBs
	update_payload twinclient.ZDBs
	new_zdb        twinclient.AddZDB
}

fn setup_zdbs_test() (twinclient.Client, ZDBsTestData) {
	redis_server := 'localhost:6379'
	twin_id := 133
	mut client := twinclient.init(redis_server, twin_id) or {
		panic('Fail in setup_zdb_test with error: $err')
	}
	mut data := ZDBsTestData{
		payload: twinclient.ZDBs{
			name: 'testingzdb'
			zdbs: [
				twinclient.ZDB{
					name: 'testzdb1'
					node_id: 5
					mode: 'seq'
					disk_size: 10
					public_namespace: false
					password: 'testtest'
				},
				twinclient.ZDB{
					name: 'testzdb2'
					node_id: 5
					mode: 'seq'
					disk_size: 10
					public_namespace: false
					password: 'testest'
				},
			]
			description: 'This is v client trial'
		}
	}
	data.update_payload = twinclient.ZDBs{
		...data.payload
		metadata: 'ZDBs'
	}
	data.new_zdb = twinclient.AddZDB{
		deployment_name: data.payload.name
		name: 'testzdb3'
		node_id: 5
		mode: 'seq'
		disk_size: 10
		public_namespace: false
		password: 'testtest'
	}
	return client, data
}


pub fn test_deploy_zdb() {
	mut client, data := setup_zdbs_test()

	println('------------- Deploy ZDB -------------')
	zdbs := client.deploy_zdbs(data.payload) or { panic(err) }
	defer {
		client.delete_zdbs(data.payload.name) or { panic(err) }
	}

	assert zdbs.contracts.created.len == 1
	assert zdbs.contracts.updated.len == 0
	assert zdbs.contracts.deleted.len == 0
}

pub fn test_list_zdbs() {
	mut client, data := setup_zdbs_test()

	zdbs := client.deploy_zdbs(data.payload) or { panic(err) }
	defer {
		client.delete_zdbs(data.payload.name) or { panic(err) }
	}

	all_my_zdbs := client.list_zdbs() or { panic(err) }
	assert data.payload.name in all_my_zdbs
}

pub fn test_update_vm() {
	mut client, data := setup_zdbs_test()

	println('------------- Deploy ZDB -------------')
	zdbs := client.deploy_zdbs(data.payload) or { panic(err) }
	defer {
		client.delete_zdbs(data.payload.name) or { panic(err) }

	update_zdbs_deployment := client.update_zdbs(data.update_payload) or { panic(err) }
	assert update_zdbs_deployment.contracts.created.len == 0
	assert update_zdbs_deployment.contracts.updated.len == 1
	assert update_zdbs_deployment.contracts.deleted.len == 0
}
