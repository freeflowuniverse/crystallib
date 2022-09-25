module twinclient

import os.cmdline
import os

struct TwinTestData {
	new_twin_ip       string
	my_twin_id        u32
	account_id        string
	twin_id_to_delete u32
}

fn setup_twin_test() (Client, TwinTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_kvstore_test with error: $err')
	}

	data := TwinTestData{
		my_twin_id: 73
		account_id: '5Fk18xUkcFLTtURxa2aXb4SrLiHJoZEBt3McjbNERwSo548Q'
	}
	return client, data
}

fn t0_create_twin(mut client Client, data TwinTestData) {
	println('--------- Create Twin ---------')
	new_twin := client.create_twin(data.new_twin_ip) or { panic(err) }
	assert new_twin.ip == data.new_twin_ip
	println(new_twin)
}

fn t1_get_twin(mut client Client, data TwinTestData) {
	println('--------- Get Twin ---------')
	twin := client.get_twin(data.my_twin_id) or { panic(err) }
	assert twin.account_id == data.account_id
	println('Twin:: $twin')
}

fn t2_get_twin_by_account_id(mut client Client, data TwinTestData) {
	println('--------- Get Twin Id By Account Id ---------')
	twin_id := client.get_twin_id_by_account_id(data.account_id) or { panic(err) }
	assert twin_id == data.my_twin_id
	println('Twin ID:: $twin_id')
}

fn t3_get_my_twin(mut client Client, data TwinTestData) {
	println('--------- Get My Twin ---------')
	my_twin_id := client.get_my_twin_id() or { panic(err) }
	assert my_twin_id == data.my_twin_id
	println('My Twin ID:: $my_twin_id')
}

fn t4_list_twin(mut client Client) {
	println('--------- List Twin ---------')
	twins := client.list_twins() or { panic(err) }
	assert twins != []Twin{}
	println('Found $twins.len twins')
}

// TAKE CARE, YOUR TWIN WILL BE DELETED HERE
// COMMENT THIS PART IF YOU DON'T WANT TO DELETE IT
fn t5_delete_twin(mut client Client, data TwinTestData) {
	println('--------- Delete Twin ---------')
	deleted_twin_id := client.delete_twin(data.twin_id_to_delete) or { panic(err) }
	println('Twin [$deleted_twin_id] deleted')
}

pub fn test_twins() {
	mut client, data := setup_twin_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])

	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_create_twin', 't1_get_twin', 't2_get_twin_by_account_id', 't3_get_my_twin',
		't4_list_twin', 't5_delete_twin']
	for tc in cmd_test {
		match tc {
			't0_create_twin' {
				t0_create_twin(mut client, data)
			}
			't1_get_twin' {
				t1_get_twin(mut client, data)
			}
			't2_get_twin_by_account_id' {
				t2_get_twin_by_account_id(mut client, data)
			}
			't3_get_my_twin' {
				t3_get_my_twin(mut client, data)
			}
			't4_list_twin' {
				t4_list_twin(mut client)
			}
			't5_delete_twin' {
				t5_delete_twin(mut client, data)
			}
			'all' {
				// t0_create_twin(mut client, data)
				t1_get_twin(mut client, data)
				t2_get_twin_by_account_id(mut client, data)
				t3_get_my_twin(mut client, data)
				t4_list_twin(mut client)
				// t5_delete_twin(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
