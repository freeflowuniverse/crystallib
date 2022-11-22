module tests

import freeflowuniverse.crystallib.twinclient as tw
import rand

fn test_tfchain_list_no_accounts() ! {
	// List empty [] => there are no tfchain accounts.
	mut client, user := setup_tests('alice')!
	tfchain_accounts := client.tfchain_list()!
	assert tfchain_accounts == []tw.BlockChainModel{}
}

fn test_tfchain_create_alice_account() ! {
	// Create new tfchain account for alice.
	mut client, user := setup_tests('alice')!
	mut u := users
	ip := rand.choose<string>(random_ip, 1) or { [random_ip[0]] }
	created := client.tfchain_create(user.name, ip[0])!
	assert created.name == user.name
	u.set('alice', .name, created.name)
	u.set('alice', .mnemonic, created.mnemonic)
	u.set('alice', .public_key, created.public_key)
	u.set('alice', .blockchain_type, created.blockchain_type)
}

fn test_tfchain_init_alice_account_wrong_seeds() ! {
	// initialize alice account
	mut client, user := setup_tests('alice')!
	assert user.mnemonic != ''
	client.tfchain_init(user.name, user.mnemonic + 'Just for test if it wrong') or {
		assert err.msg() == 'Invalid mnemonic or secret seed! Check your input.'
		return
	}
}

fn test_tfchain_init_alice_account() ! {
	// initialize alice account
	mut client, user := setup_tests('alice')!
	assert user.mnemonic != ''
	client.tfchain_init(user.name, user.mnemonic) or {
		assert err.msg() == 'An account with the same name $user.name already exists'
		return
	}
}

fn test_tfchain_get_alice_account() ! {
	// get alice account
	mut client, user := setup_tests('alice')!
	founded := client.tfchain_get(user.name)!
	assert founded.name == user.name
}

fn test_tfchain_alice_account_isexist() ! {
	// get alice account
	mut client, user := setup_tests('alice')!
	founded := client.tfchain_exist(user.name)!
	assert founded == true
}

fn test_tfchain_alice_balance_by_address() ! {
	// get alice account
	mut client, user := setup_tests('alice')!
	client.tfchain_delete(user.name)!
	created := client.tfchain_init(user.name, user.mnemonic)!
	balance := client.tfchain_balance_by_address(created.address)!
	assert balance.reserved == 0
	assert balance.fee_frozen == 0
	assert balance.fee_frozen == 0
}

fn test_tfchain_create_bob_account() ! {
	// Create new tfchain account for bob.
	mut client, user := setup_tests('bob')!
	mut u := users
	ip := rand.choose<string>(random_ip, 1) or { [random_ip[0]] }
	created := client.tfchain_create(user.name, ip[0])!
	assert created.name == user.name
	u.set('bob', .name, created.name)
	u.set('bob', .mnemonic, created.mnemonic)
	u.set('bob', .public_key, created.public_key)
	u.set('bob', .blockchain_type, created.blockchain_type)
}

fn test_tfchain_delete_account_not_exist() ! {
	// Delete acount not exist.
	mut client, user := setup_tests('mando')!
	client.tfchain_delete(user.name) or {
		assert err.msg() == "Couldn't find an account with name $user.name"
		return
	}
}

fn test_tfchain_init_baz_account() ! {
	// initialize baz account
	mut client, user := setup_tests('baz')!
	ip := rand.choose<string>(random_ip, 1) or { [random_ip[0]] }
	fake_account := client.tfchain_create('fake', ip[0])!
	created := client.tfchain_init(user.name, fake_account.mnemonic)!
	assert created.address != ''
}

fn test_tfchain_delete_alice_account() ! {
	// Delete alice account.
	mut client, user := setup_tests('alice')!
	deleted := client.tfchain_delete(user.name)!
	assert deleted == true
}

fn test_tfchain_delete_fake_account() ! {
	// Delete fake account.
	mut client, user := setup_tests('fake')!
	deleted := client.tfchain_delete(user.name)!
	assert deleted == true
}

fn test_tfchain_delete_bob_account() ! {
	// Delete bob account.
	mut client, user := setup_tests('bob')!
	deleted := client.tfchain_delete(user.name)!
	assert deleted == true
}

fn test_tfchain_delete_baz_account() ! {
	// Delete bob account.
	mut client, user := setup_tests('baz')!
	deleted := client.tfchain_delete(user.name)!
	assert deleted == true
}

// Issues above
// fn test_tfchain_alice_update()! {
// 	// update alice account
// 	mut client, user := setup_tests("alice")!
// 	founded := client.tfchain_update(
// 		user.name, user.mnemonic
// 	)!
// 	assert founded.name == user.name
// }
