module tests
import freeflowuniverse.crystallib.twinclient as tw
import rand


fn test_tfchain_list_no_accounts()? {
	// List empty [] => there are no tfchain accounts.
	mut client, data := setup_tests("alice")?
	algorand_accounts := client.tfchain_list()?
	assert algorand_accounts == []tw.BlockChainModel{}
}


// fn test_tfchain_create_alice_account()? {
// 	// Create new tfchain account for alice.
// 	mut client, data := setup_tests()?
// 	ip := rand.choose<string>(random_ip, 1) or {[random_ip[0]]}
// 	created := client.tfchain_create(data.user1.name, ip[0])?
// 	assert created.name == data.user1.name
// }

// fn test_tfchain_create_bob_account()? {
// 	// Create new tfchain account for bob.
// 	mut client, data := setup_tests()?
// 	ip := rand.choose<string>(random_ip, 1) or {[random_ip[0]]}
// 	created := client.tfchain_create(data.user2.name, ip[0])?
// 	assert created.name == data.user2.name
// }

// fn test_tfchain_list_alice_and_bob_accounts()? {
// 	// Trying to list all accounts and assert if the account is founds.
// 	mut client, data := setup_tests()?
// 	tfchain_accounts := client.tfchain_list()?
// 	assert tfchain_accounts[0].name == data.user1.name
// 	assert tfchain_accounts[1].name == data.user2.name
// }

// fn test_tfchain_delete_account_not_exist()? {
// 	// Delete acount not exist.
// 	mut client, data := setup_tests()?
// 	client.tfchain_delete(data.user3.name) or {
// 		assert err.msg() == "Couldn't find an account with name $data.user3.name"
// 		return
// 	}
// }

// fn test_tfchain_init_alice_account()? {
// 	// initialize alice account
// 	mut client, data := setup_tests()?
// 	assert data.user1.mnemonic != ""
// 	client.tfchain_init(data.user1.name, data.user1.mnemonic) or {
// 		assert err.msg() == "Invalid mnemonic or secret seed! Check your input."
// 		return
// 	}
// }

// fn test_tfchain_init_baz_account()? {
// 	// initialize baz account
// 	mut client, data := setup_tests()?
// 	created := client.tfchain_init(data.user3.name, data.user3.mnemonic)?
// 	assert created.name == data.user3.name
// }

// fn test_tfchain_get_alice_account()? {
// 	// get alice account
// 	mut client, data := setup_tests()?
// 	founded := client.tfchain_get(data.user1.name)?
// 	assert founded.name == data.user1.name
// }

// fn test_tfchain_delete_alice_account()? {
// 	// Delete alice account.
// 	mut client, data := setup_tests()?
// 	deleted := client.tfchain_delete(data.user1.name)?
// 	assert deleted == true
// }

// fn test_tfchain_delete_bob_account()? {
// 	// Delete bob account.
// 	mut client, data := setup_tests()?
// 	deleted := client.tfchain_delete(data.user2.name)?
// 	assert deleted == true
// }