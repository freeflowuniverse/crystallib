module twinclient

struct ZDBsTestData {
mut:
	payload        ZDBs
	update_payload ZDBs
	new_zdb        AddZDB
}

pub fn setup_zdb_test() (Client, ZDBsTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_zdb_test with error: $err')
	}
	mut data := ZDBsTestData{
		payload: ZDBs{
			name: 'essamzdbs'
			zdbs: [
				ZDB{
					name: 'essamzdb1'
					node_id: 5
					mode: 'seq'
					disk_size: 10
					public_namespace: false
					password: 'essam1234'
				},
				ZDB{
					name: 'essamzdb2'
					node_id: 5
					mode: 'seq'
					disk_size: 10
					public_namespace: false
					password: 'essam1234'
				},
			]
			description: 'This is v client trial'
		}
	}
	data.update_payload = ZDBs{
		...data.payload
		metadata: 'ZDBs'
	}
	data.new_zdb = AddZDB{
		deployment_name: data.payload.name
		name: 'essamzdb3'
		node_id: 5
		mode: 'seq'
		disk_size: 10
		public_namespace: false
		password: 'essam1234'
	}
	return client, data
}

pub fn test_deploy_zdbs() {
	mut client, data := setup_zdb_test()

	println('--------- Deploy ZDB ---------')
	deploy_zdbs := client.deploy_zdbs(data.payload) or { panic(err) }
	println(deploy_zdbs)
}

pub fn test_list_zdbs() {
	mut client, data := setup_zdb_test()
	println('--------- List Deployed ZDBs ---------')
	all_my_zdbs := client.list_zdbs() or { panic(err) }
	assert data.payload.name in all_my_zdbs
	println(all_my_zdbs)
}

pub fn test_get_zdbs() {
	mut client, data := setup_zdb_test()
	println('--------- Get ZDB ---------')
	get_zdbs_deployment := client.get_zdbs(data.payload.name) or { panic(err) }
	println(get_zdbs_deployment)
}

// pub fn test_update_zdbs() {
// }

pub fn test_add_zdb() {
	mut client, data := setup_zdb_test()
	println('--------- Add ZDB ---------')
	add_zdb_result := client.add_zdb(data.new_zdb) or { panic(err) }
	println(add_zdb_result)
}

pub fn test_delete_zdb() {
	mut client, data := setup_zdb_test()
	println('--------- Delete ZDB ---------')
	delete_zdb_result := client.delete_zdb(
		name: data.new_zdb.name
		deployment_name: data.payload.name
	) or { panic(err) }
	println(delete_zdb_result)
}

pub fn test_delete_zdbs() {
	mut client, data := setup_zdb_test()
	println('--------- Delete ZDBs ---------')
	delete_zdbs := client.delete_zdbs(data.payload.name) or { panic(err) }
	println(delete_zdbs)
}
