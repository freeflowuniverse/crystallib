module twinclient

import os.cmdline
import os

struct KVStoreTestData {
	key        string
	value      string
	account_id string
}

fn setup_kvstore_test() (Client, KVStoreTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_kvstore_test with error: $err')
	}
	data := KVStoreTestData{
		key: 'testKey1'
		value: 'This is a test value'
		account_id: '5Fk18xUkcFLTtURxa2aXb4SrLiHJoZEBt3McjbNERwSo548Q'
	}
	return client, data
}

fn t0_set_kvstore(mut client Client, data KVStoreTestData) {
	println('--------- Set Record in KVStore ---------')
	set_result := client.set_kvstore(data.key, data.value) or { panic(err) }
	assert set_result == '"$data.account_id"'
	println('Set Done!')
}

fn t1_get_kvstore(mut client Client, data KVStoreTestData) {
	println('--------- Get Record from KVStore ---------')
	get_value := client.get_kvstore(data.key) or { panic(err) }
	assert get_value == '"$data.value"'
	println('Value of $data.key :: $get_value')
}

fn t2_list_kvstore(mut client Client, data KVStoreTestData) {
	println('--------- List all Records from KVStore ---------')
	list_keys := client.list_kvstore() or { panic(err) }
	assert data.key in list_keys
	println('KVStore Keys:: $list_keys')
}

fn t3_remove_kvstore(mut client Client, data KVStoreTestData) {
	println('--------- Remove Record from KVStore ---------')
	remove_result := client.remove_kvstore(data.key) or { panic(err) }
	assert remove_result == '"$data.account_id"'
	println('Remove Done!')
}

// TAKE CARE, YOUR KVStore WILL BE DELETED HERE
// COMMENT THIS PART IF YOU DON'T WANT TO DELETE IT
fn t4_remove_all_kvstore(mut client Client, data KVStoreTestData) {
	println('--------- Remove All Records from KVStore ---------')
	remove_all_result := client.remove_all_kvstore() or { panic(err) }
	println('Remove All Done!, Your KVStore empty now')
}

pub fn test_kvstore() {
	mut client, data := setup_kvstore_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_set_kvstore', 't1_get_kvstore', 't2_list_kvstore', 't3_remove_kvstore',
		't4_remove_all_kvstore']

	for tc in cmd_test {
		match tc {
			't0_set_kvstore' {
				t0_set_kvstore(mut client, data)
			}
			't1_get_kvstore' {
				t1_get_kvstore(mut client, data)
			}
			't2_list_kvstore' {
				t2_list_kvstore(mut client, data)
			}
			't3_remove_kvstore' {
				t3_remove_kvstore(mut client, data)
			}
			't4_remove_all_kvstore' {
				t4_remove_all_kvstore(mut client, data)
			}
			'all' {
				t0_set_kvstore(mut client, data)
				t1_get_kvstore(mut client, data)
				t2_list_kvstore(mut client, data)
				t3_remove_kvstore(mut client, data)
				t4_remove_all_kvstore(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
