module twinclient

import os.cmdline
import os

fn setup_qsfs_zdbs_test() (Client, QSFSZDBs) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_qsfs_zdbs_test with error: $err')
	}
	mut data := QSFSZDBs{
		name: 'qsfsZdbs1'
		count: 4
		node_ids: [u32(3), u32(5)]
		disk_size: 10
		password: '12345678'
	}
	return client, data
}

fn t0_deploy_qsfs_zdbs(mut client Client, data QSFSZDBs) {
	println('--------- Deploy QSFSZDBs ---------')
	deploy_qsfs_zdbs := client.deploy_qsfs_zdbs(data) or { panic(err) }
	println(deploy_qsfs_zdbs)
}

fn t1_list_qsfs_zdbs(mut client Client, data QSFSZDBs) {
	println('--------- List Deployed QSFSZDBs ---------')
	all_my_qsfs_zdbs := client.list_qsfs_zdbs() or { panic(err) }
	assert data.name in all_my_qsfs_zdbs
	println(all_my_qsfs_zdbs)
}

fn t2_get_qsfs_zdbs(mut client Client, data QSFSZDBs) {
	println('--------- Get QSFSZDBs ---------')
	get_qsfs_zdbs_deployment := client.get_qsfs_zdbs(data.name) or { panic(err) }
	println(get_qsfs_zdbs_deployment)
}

fn t3_delete_qsfs_zdbs(mut client Client, data QSFSZDBs) {
	println('--------- Delete QSFSZDBs ---------')
	delete_qsfs_zdbs := client.delete_qsfs_zdbs(data.name) or { panic(err) }
	println(delete_qsfs_zdbs)
}

pub fn test_qsfs_zdbs() {
	mut client, data := setup_qsfs_zdbs_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_deploy_qsfs_zdbs', 't1_list_qsfs_zdbs', 't2_get_qsfs_zdbs',
		't3_delete_qsfs_zdbs']
	for tc in cmd_test {
		match tc {
			't0_deploy_qsfs_zdbs' {
				t0_deploy_qsfs_zdbs(mut client, data)
			}
			't1_list_qsfs_zdbs' {
				t1_list_qsfs_zdbs(mut client, data)
			}
			't2_get_qsfs_zdbs' {
				t2_get_qsfs_zdbs(mut client, data)
			}
			't3_delete_qsfs_zdbs' {
				t3_delete_qsfs_zdbs(mut client, data)
			}
			'all' {
				t0_deploy_qsfs_zdbs(mut client, data)
				t1_list_qsfs_zdbs(mut client, data)
				t2_get_qsfs_zdbs(mut client, data)
				t3_delete_qsfs_zdbs(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
