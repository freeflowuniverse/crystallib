module twinclient

import os.cmdline
import os

struct ZDBsTestData {
mut:
	payload        ZDBs
	update_payload ZDBs
	new_zdb        AddZDB
}

fn setup_zdbs_test() (Client, ZDBsTestData) {
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

fn t0_deploy_zdbs(mut client Client, data ZDBsTestData) {
	println('--------- Deploy ZDBs ---------')
	deploy_zdbs := client.deploy_zdbs(data.payload) or { panic(err) }
	println(deploy_zdbs)
}

fn t1_list_zdbs(mut client Client, data ZDBsTestData) {
	println('--------- List Deployed ZDBs ---------')
	all_my_zdbs := client.list_zdbs() or { panic(err) }
	assert data.payload.name in all_my_zdbs
	println(all_my_zdbs)
}

fn t2_get_zdbs(mut client Client, data ZDBsTestData) {
	println('--------- Get ZDBs ---------')
	get_zdbs_deployment := client.get_zdbs(data.payload.name) or { panic(err) }
	println(get_zdbs_deployment)
}

fn t3_update_zdbs(mut client Client, data ZDBsTestData) {
	println('--------- Update ZDBs ---------')
	update_zdbs_deployment := client.update_zdbs(data.update_payload) or { panic(err) }
	println(update_zdbs_deployment)
}

fn t4_add_zdb(mut client Client, data ZDBsTestData) {
	println('--------- Add ZDB ---------')
	add_zdb_result := client.add_zdb(data.new_zdb) or { panic(err) }
	println(add_zdb_result)
}

fn t5_delete_zdb(mut client Client, data ZDBsTestData) {
	println('--------- Delete ZDB ---------')
	delete_zdb_result := client.delete_zdb(
		name: data.new_zdb.name
		deployment_name: data.payload.name
	) or { panic(err) }
	println(delete_zdb_result)
}

fn t6_delete_zdbs(mut client Client, data ZDBsTestData) {
	println('--------- Delete ZDBs ---------')
	delete_zdbs := client.delete_zdbs(data.payload.name) or { panic(err) }
	println(delete_zdbs)
}

pub fn test_zdbs() {
	mut client, data := setup_zdbs_test()
	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_deploy_zdbs', 't1_list_zdbs', 't2_get_zdbs', 't3_update_zdbs', 't4_add_zdb',
		't5_delete_zdb', 't6_delete_zdbs']

	for tc in cmd_test {
		match tc {
			't0_deploy_zdbs' {
				t0_deploy_zdbs(mut client, data)
			}
			't1_list_zdbs' {
				t1_list_zdbs(mut client, data)
			}
			't2_get_zdbs' {
				t2_get_zdbs(mut client, data)
			}
			't3_update_zdbs' {
				t3_update_zdbs(mut client, data)
			}
			't4_add_zdb' {
				t4_add_zdb(mut client, data)
			}
			't5_delete_zdb' {
				t5_delete_zdb(mut client, data)
			}
			't6_delete_zdbs' {
				t6_delete_zdbs(mut client, data)
			}
			'all' {
				t0_deploy_zdbs(mut client, data)
				t1_list_zdbs(mut client, data)
				t2_get_zdbs(mut client, data)
				// t3_update_zdbs(mut client, data)
				t4_add_zdb(mut client, data)
				t5_delete_zdb(mut client, data)
				t6_delete_zdbs(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
