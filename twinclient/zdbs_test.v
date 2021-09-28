module twinclient

pub fn test_zdbs() {
	mut twin_dest := 49 // ADD TWIN ID.
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	mut zdbs := []ZDB{}
	zdbs << ZDB{
		name: 'essamzdb1'
		node_id: 3
		mode: 'seq'
		disk_size: 10
		disk_type: 'hdd'
		public: false
		namespace: 'essamnamespace'
		password: 'essam1234'
	}
	zdbs << ZDB{
		name: 'essamzdb2'
		node_id: 3
		mode: 'seq'
		disk_size: 10
		disk_type: 'hdd'
		public: false
		namespace: 'essamnamespace'
		password: 'essam1234'
	}
	payload := DeployZDBPayload{
		name: 'essamzdbs'
		zdbs: zdbs
		metadata: ''
		description: 'This is v client trial'
	}

	// Deploy ZDBS
	deploy_zdbs := tw.deploy_zdbs(payload) or { panic(err) }
	println('--------- Deploy ZDB ---------')
	println(deploy_zdbs)

	// Add ZDB
	add_zdb_instance := ZDB{
		name: 'essamzdb3'
		node_id: 3
		mode: 'seq'
		disk_size: 10
		disk_type: 'hdd'
		public: false
		namespace: 'essamnamespace'
		password: 'essam1234'
	}
	add_zdb_result := tw.add_zdb(payload.name, add_zdb_instance) or { panic(err) }
	println('--------- Add ZDB ---------')
	println(add_zdb_result)

	// Delete ZDB
	delete_zdb_name := add_zdb_instance.name
	delete_zdb_result := tw.delete_zdb(payload.name, delete_zdb_name) or { panic(err) }
	println('--------- Delete ZDB ---------')
	println(delete_zdb_result)

	// Get ZDBS
	get_zdbs_deployment := tw.get_zdbs(payload.name) or { panic(err) }
	println('--------- Get ZDB ---------')
	println(get_zdbs_deployment)

	// List Deployed Machines
	all_my_zdbs := tw.list_zdbs() or { panic(err) }
	assert payload.name in all_my_zdbs
	println('--------- List Deployed ZDBs for Each User ---------')
	println(all_my_zdbs)

	// Delete Deployed Machine
	delete_zdbs := tw.delete_zdbs(payload.name) or { panic(err) }
	println('--------- Delete ZDBs ---------')
	println(delete_zdbs)
}
