module twinclient

fn setup_qsfs_zdbs_test() (Client, QSFSZDBs) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_qsfs_zdbs_test with error: $err')
	}
	mut data := QSFSZDBs{
		name: 'qsfsZdbs1'
		count: 3
		node_ids: [u32(3), u32(5)]
		disk_size: 10
		password: '12345678'
	}
	return client, data
}

pub fn test_deploy_qsfs_zdbs() {
	mut client, data := setup_qsfs_zdbs_test()

	println('--------- Deploy QSFSZDBs ---------')
	deploy_qsfs_zdbs := client.deploy_qsfs_zdbs(data) or { panic(err) }
	println(deploy_qsfs_zdbs)
}

pub fn test_list_qsfs_zdbs() {
	mut client, data := setup_qsfs_zdbs_test()
	println('--------- List Deployed QSFSZDBs ---------')
	all_my_qsfs_zdbs := client.list_qsfs_zdbs() or { panic(err) }
	assert data.name in all_my_qsfs_zdbs
	println(all_my_qsfs_zdbs)
}

pub fn test_get_qsfs_zdbs() {
	mut client, data := setup_qsfs_zdbs_test()
	println('--------- Get QSFSZDBs ---------')
	get_qsfs_zdbs_deployment := client.get_qsfs_zdbs(data.name) or { panic(err) }
	println(get_qsfs_zdbs_deployment)
}

pub fn test_delete_qsfs_zdbs() {
	mut client, data := setup_qsfs_zdbs_test()
	println('--------- Delete QSFSZDBs ---------')
	delete_qsfs_zdbs := client.delete_qsfs_zdbs(data.name) or { panic(err) }
	println(delete_qsfs_zdbs)
}
