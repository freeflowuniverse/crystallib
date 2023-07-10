module tests

import freeflowuniverse.crystallib.twinclient as tw

fn test_algorand_list_no_accounts() ? {
	// List empty [] => there are no algorand accounts.
	mut client, user := setup_tests('alice')?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts == []tw.BlockChainModel{}
}

fn test_algorand_create_alice_account() ? {
	// Create new algorand account for alice.
	mut client, mut user := setup_tests('alice')?
	mut u := users
	created := client.algorand_create(user.name)?
	assert created.name != ''
	assert created.mnemonic != ''
	assert created.public_key != ''
	assert created.blockchain_type != ''
	u.set('alice', .name, created.name)
	u.set('alice', .mnemonic, created.mnemonic)
	u.set('alice', .public_key, created.public_key)
	u.set('alice', .blockchain_type, created.blockchain_type)
}

fn test_algorand_init_alice_account() {
	// initialize alice account
	mut client, mut user := setup_tests('alice')?
	assert user.mnemonic != ''
	client.algorand_init(user.name, user.mnemonic) or {
		assert err.msg() == 'A wallet with the same name $user.name already exists'
		return
	}
}

fn test_algorand_get_alice_account() ? {
	// get alice account
	mut client, user := setup_tests('alice')?
	founded := client.algorand_get(user.name)?
	assert founded.name == user.name
}

fn test_algorand_create_bob_account() ? {
	// Create new algorand account for bob.
	mut client, mut user := setup_tests('bob')?
	mut u := users
	created := client.algorand_create(user.name)?
	assert created.name != ''
	assert created.mnemonic != ''
	assert created.public_key != ''
	assert created.blockchain_type != ''
	u.set('bob', .name, created.name)
	u.set('bob', .mnemonic, created.mnemonic)
	u.set('bob', .public_key, created.public_key)
	u.set('bob', .blockchain_type, created.blockchain_type)
}

fn test_algorand_init_bob_account() {
	// initialize bob account
	mut client, mut user := setup_tests('bob')?
	assert user.mnemonic != ''
	client.algorand_init(user.name, user.mnemonic) or {
		assert err.msg() == 'A wallet with the same name $user.name already exists'
		return
	}
}

fn test_algorand_list_alice_and_bob_accounts() ? {
	// Trying to list all accounts and assert if the account is founds.
	mut client, user := setup_tests('bob')?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts.len >= 2
}

fn test_algorand_list_accounts() ? {
	// List [] => there are around 3 algorand accounts.
	mut client, user := setup_tests('bob')?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts.len > 1
}

fn test_algorand_init_baz_account() ? {
	// initialize baz account
	mut client, user := setup_tests('baz')?
	mut u := users
	mut fake_account := client.algorand_create('fake')?
	created := client.algorand_init(user.name, fake_account.mnemonic)?
	u.set('baz', .mnemonic, fake_account.mnemonic)
	assert created.address != ''
}

fn test_algorand_assets_by_baz_address() ? {
	// get all assets by baz address
	mut client, user := setup_tests('baz')?
	deleted := client.algorand_delete(user.name)?
	created := client.algorand_init(user.name, user.mnemonic)?
	assert created.address != ''
	assets := client.algorand_assets_by_address(created.address)?
	assert assets.amount == 0
	assert assets.asset == ''
}

fn test_algorand_delete_alice_account() ? {
	// Delete alice account.
	mut client, user := setup_tests('alice')?
	deleted := client.algorand_delete(user.name)?
	assert deleted == true
}

fn test_algorand_delete_baz_account() ? {
	// Delete alice account.
	mut client, user := setup_tests('baz')?
	deleted := client.algorand_delete(user.name)?
	assert deleted == true
}

fn test_algorand_delete_bob_account() ? {
	// Delete bob account.
	mut client, user := setup_tests('bob')?
	deleted := client.algorand_delete(user.name)?
	assert deleted == true
}

fn test_algorand_delete_fake_account() ? {
	// Delete bob account.
	mut client, user := setup_tests('fake')?
	deleted := client.algorand_delete(user.name)?
	assert deleted == true
}

fn test_algorand_delete_account_not_exist() ? {
	// Delete acount not exist.
	mut client, user := setup_tests('alice')?
	client.algorand_delete(user.name) or {
		assert err.msg() == "Couldn't find a wallet with name $user.name"
		return
	}
}

// Issues above
// fn test_algorand_assets_for_alice()? {
// 	// Delete bob account.
// 	mut client, user := setup_tests()?
// 	deleted := client.algorand_assets(user.name)?
// 	// assert deleted == true
// }

// fn test_algorand_account_exist()? {
// 	println('--------- Check if algorand account exist ---------')
// 	// There are no algorand accounts
// 	mut client, user := setup_tests()?
// 	exist := client.algorand_exist(user.name)?
// 	assert exist == false
// }

// fn test_algorand_alice_pay_to_bob()? {
// 	// test pay for bob from alice.
// 	mut client, user := setup_tests()?
// 	deleted := client.algorand_delete(user.user2.name)? // Bob
// 	created := client.algorand_init(user.user2.name, user.user2.mnemonic)?
// 	assert created.address != ""
// 	paid := client.algorand_pay(
// 		user.name, created.address, 1, "Is Paid?"
// 	)?

// }
