module twinclient

import os.cmdline
import os

fn setup_balance_test() (Client, BalanceTransfer) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_balance_test with error: $err')
	}
	data := BalanceTransfer{
		address: '5D2etsCt37ucdTvybV8PaeQzmoUsNp7RzxZQGJosmY8PUvKQ'
		amount: 0.1
	}
	return client, data
}

fn t0_get_balance(mut client Client, data BalanceTransfer) {
	println('--------- Get Balance ---------')
	balance := client.get_balance(data.address) or { panic(err) }
	println(balance)
}

fn t1_get_my_balance(mut client Client) {
	println('--------- Get MyBalance ---------')
	my_balance := client.get_my_balance() or { panic(err) }
	println(my_balance)
}

fn t2_transfer_balance(mut client Client, data BalanceTransfer) {
	println('--------- Transfer Balance ---------')
	client.transfer_balance(data) or { panic(err) }
}

pub fn test_balance() {
	mut client, data := setup_balance_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_get_balance', 't1_get_my_balance', 't2_transfer_balance']

	for tc in cmd_test {
		match tc {
			't0_get_balance' {
				t0_get_balance(mut client, data)
			}
			't1_get_my_balance' {
				t1_get_my_balance(mut client)
			}
			't2_transfer_balance' {
				t2_transfer_balance(mut client, data)
			}
			'all' {
				t0_get_balance(mut client, data)
				t1_get_my_balance(mut client)
				t2_transfer_balance(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
