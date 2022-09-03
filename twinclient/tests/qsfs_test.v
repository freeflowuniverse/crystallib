import twinclient

fn setup_qsfs_zdbs_test() (twinclient.Client, twinclient.QSFSZDBs) {
	redis_server := 'localhost:6379'
	twin_id := 133
	mut client := twinclient.init(redis_server, twin_id) or {
		panic('Fail in setup_qsfs_zdbs_test with error: $err')
	}
	mut data := twinclient.QSFSZDBs{
		name: 'qsfsZdbs1'
		count: 4
		node_ids: [u32(3), u32(5)]
		disk_size: 10
		password: 'testtest'
	}
	return client, data
}

pub fn test_deploy_vm() {
	mut client, data := setup_qsfs_zdbs_test()

	println('------------- Deploy QSFS -------------')
	deploy_qsfs_zdbs := client.deploy_qsfs_zdbs(data) or { panic(err) }
	defer {
		client.delete_qsfs_zdbs(data.name) or { panic(err) }
	}

	assert deploy_qsfs_zdbs.contracts.created.len == 1
	assert deploy_qsfs_zdbs.contracts.updated.len == 0
	assert deploy_qsfs_zdbs.contracts.deleted.len == 0
}

pub fn test_list_vm() {
	mut client, data := setup_qsfs_zdbs_test()

	println('------------- Deploy QSFS -------------')
	deploy_qsfs_zdbs := client.deploy_qsfs_zdbs(data) or { panic(err) }
	defer {
		client.delete_qsfs_zdbs(data.name) or { panic(err) }
	}

	all_my_qsfs_zdbs := client.list_qsfs_zdbs() or { panic(err) }
	assert data.name in all_my_qsfs_zdbs
}
