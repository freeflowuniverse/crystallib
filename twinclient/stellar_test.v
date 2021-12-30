module twinclient

import os.cmdline
import os

struct StellarTestData {
mut:
	src_wallet      StellarWallet
	imported_wallet StellarWallet
}

fn prepare_wallet(mut client Client, wallet StellarWallet) StellarWallet {
	mut prepared_wallet := StellarWallet{}
	// Check if src wallet exists, get it, else import it.
	is_src_exist := client.is_wallet_exist(wallet.name) or { panic(err) }
	if is_src_exist {
		// Get Wallet
		prepared_wallet = client.get_wallet(wallet.name) or { panic(err) }
	} else {
		// Import Wallet
		prepared_wallet = client.import_wallet(wallet) or { panic(err) }
	}
	if prepared_wallet.address == '' {
		panic("Can't get/import $wallet.name")
	}
	return prepared_wallet
}

fn setup_stellar_test() (Client, StellarTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73

	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_balance_test with error: $err')
	}
	mut data := StellarTestData{
		src_wallet: StellarWallet{
			name: 'srcwallet'
			secret: os.environ()['SOURCE_WALLET_SECRET']
		}
		imported_wallet: StellarWallet{
			name: 'mywallet'
			secret: os.environ()['WALLET_SECRET']
		}
	}
	if data.src_wallet.secret == '' {
		panic('Please add your source wallet secret in SOURCE_WALLET_SECRET to import it')
	}
	if data.imported_wallet.secret == '' {
		panic('Please add your wallet secret in WALLET_SECRET to import it')
	}
	data.src_wallet = prepare_wallet(mut client, data.src_wallet)
	data.imported_wallet = prepare_wallet(mut client, data.imported_wallet)
	return client, data
}

fn t0_list_stellar_wallets(mut client Client, data StellarTestData) {
	println('--------- List Wallets ---------')
	all_wallets := client.list_wallets() or { panic(err) }
	assert data.imported_wallet.name in all_wallets
	println(all_wallets)
}

fn t1_get_balance_by_stellar_wallet_name(mut client Client, data StellarTestData) {
	println('--------- Balance By Wallet Name ---------')
	balance_by_name := client.balance_by_name(data.imported_wallet.name) or { panic(err) }
	println(balance_by_name)
}

fn t2_get_balance_by_stellar_wallet_address(mut client Client, data StellarTestData) {
	println('--------- Balance By Wallet Name ---------')
	balance_by_name := client.balance_by_address(data.imported_wallet.address) or { panic(err) }
	println(balance_by_name)
}

fn t3_stellar_transfer(mut client Client, data StellarTestData) {
	println('--------- Transfer ---------')
	transfer_link := client.stellar_transfer(
		from_name: data.src_wallet.name
		target_address: data.imported_wallet.address
		asset: 'TFT'
		amount: 0.1
		memo: ''
	) or { panic(err) }
	transfer_back := client.stellar_transfer(
		from_name: data.imported_wallet.name
		target_address: data.src_wallet.address
		asset: 'TFT'
		amount: 0.09
		memo: ''
	) or { panic(err) }
}

fn t4_update_stellar_wallet_secret(mut client Client, data StellarTestData) {
	// Update
	new_secret := os.environ()['UPDATE_WALLET_SECRET']
	if new_secret == '' {
		panic('Please add your updated wallet secret in UPDATE_WALLET_SECRET to update it')
	}
	println('--------- Update Wallet Secret ---------')
	updated_wallet := client.update_wallet(name: data.imported_wallet.name, secret: new_secret) or {
		panic(err)
	}
}

fn t5_delete_stellar_wallet(mut client Client, data StellarTestData) {
	// delete wallet
	delete_wallet := client.delete_wallet(data.imported_wallet.name) or { panic(err) }
	assert delete_wallet
	println('$data.imported_wallet.name Deleted')
}

pub fn test_stellar() {
	mut client, data := setup_stellar_test()

	mut cmd_test := cmdline.options_after(os.args, ['--test', '-t'])
	if cmd_test.len == 0 {
		cmd_test << 'all'
	}

	test_cases := ['t0_list_stellar_wallets', 't1_get_balance_by_stellar_wallet_name',
		't2_get_balance_by_stellar_wallet_address', 't3_stellar_transfer',
		't4_update_stellar_wallet_secret', 't5_delete_stellar_wallet']

	for tc in cmd_test {
		match tc {
			't0_list_stellar_wallets' {
				t0_list_stellar_wallets(mut client, data)
			}
			't1_get_balance_by_stellar_wallet_name' {
				t1_get_balance_by_stellar_wallet_name(mut client, data)
			}
			't2_get_balance_by_stellar_wallet_address' {
				t2_get_balance_by_stellar_wallet_address(mut client, data)
			}
			't3_stellar_transfer' {
				t3_stellar_transfer(mut client, data)
			}
			't4_update_stellar_wallet_secret' {
				t4_update_stellar_wallet_secret(mut client, data)
			}
			't5_delete_stellar_wallet' {
				t5_delete_stellar_wallet(mut client, data)
			}
			'all' {
				t0_list_stellar_wallets(mut client, data)
				t1_get_balance_by_stellar_wallet_name(mut client, data)
				t2_get_balance_by_stellar_wallet_address(mut client, data)
				t3_stellar_transfer(mut client, data)
				t4_update_stellar_wallet_secret(mut client, data)
				t5_delete_stellar_wallet(mut client, data)
			}
			else {
				println('Available test case:\n$test_cases, or all to run all test cases')
			}
		}
	}
}
