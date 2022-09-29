import freeflowuniverse.crystallib.twinclient as tw

const mnemonics = [
	"muscle file pear damp essence manage initial identify identify choose curtain move design stereo mom combine dish cabin neither limit dentist maximum sense absorb capital",
	"tooth lumber general mechanic census erupt raw color maze bone ball egg unfold omit poverty salt define setup asthma jeans carpet flavor awkward absent ride",
	"below library secret olympic clutch debris radio easy humble punch sock ocean axis lock consider hope can torch table old orbit address quality abandon disagree"
]

struct AlgorandDummeyData{
	// Dummey data for algorand wallets
	mut:
		user1 tw.BlockChainCreateModel
		user2 tw.BlockChainCreateModel
		user3 tw.BlockChainCreateModel
}

fn setup_http_algorand_tests()? (tw.TwinClient, AlgorandDummeyData) {
	mut transport 	:= tw.HttpTwinClient{}
	mut client 		:= tw.grid_client(transport)?
	mut alice 		:= tw.BlockChainCreateModel{name: "alice", mnemonic: mnemonics[0]}
	mut bob 		:= tw.BlockChainCreateModel{name: "bob", mnemonic: mnemonics[1]}
	mut baz 		:= tw.BlockChainCreateModel{name: "baz", mnemonic: mnemonics[2]}
	transport.init("http://localhost:3000")?
	data := AlgorandDummeyData{
		user1: alice,
		user2: bob,
		user3: baz,
	}
	return client, data
}

fn test_http_algorand_list_no_accounts()? {
	// List empty [] => there are no algorand accounts.
	mut client, data := setup_http_algorand_tests()?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts == []tw.BlockChainModel{}
}

fn test_http_algorand_algorand_create_alice_account()? {
	// Create new algorand account for alice.
	mut client, data := setup_http_algorand_tests()?
	created := client.algorand_create(data.user1.name)?
	assert created.name == data.user1.name
}

fn test_http_algorand_algorand_create_bob_account()? {
	// Create new algorand account for bob.
	mut client, data := setup_http_algorand_tests()?
	created := client.algorand_create(data.user2.name)?
	assert created.name == data.user2.name
}

fn test_http_algorand_list_alice_and_bob_accounts()? {
	// Trying to list all accounts and assert if the account is founds.
	mut client, data := setup_http_algorand_tests()?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts[0].name == data.user1.name
	assert algorand_accounts[1].name == data.user2.name
}

fn test_http_algorand_delete_account_not_exist()? {
	// Delete acount not exist.
	mut client, data := setup_http_algorand_tests()?
	client.algorand_delete(data.user3.name) or {
		assert err.msg() == "Couldn't find a wallet with name $data.user3.name"
		return
	}
}

fn test_http_algorand_init_alice_account()? {
	// initialize alice account
	mut client, data := setup_http_algorand_tests()?
	assert data.user1.mnemonic != ""
	client.algorand_init(data.user1.name, data.user1.mnemonic) or {
		assert err.msg() == "A wallet with the same name $data.user1.name already exists"
		return
	}
}

fn test_http_algorand_init_baz_account()? {
	// initialize baz account
	mut client, data := setup_http_algorand_tests()?
	created := client.algorand_init(data.user3.name, data.user3.mnemonic)?
	assert created.address != ""
}

fn test_http_algorand_get_alice_account()? {
	// get alice account
	mut client, data := setup_http_algorand_tests()?
	founded := client.algorand_get(data.user1.name)?
	assert founded.name == data.user1.name
}

fn test_http_algorand_assets_by_baz_address()? {
	// get all assets by baz address
	mut client, data := setup_http_algorand_tests()?
	deleted := client.algorand_delete(data.user3.name)?
	created := client.algorand_init(data.user3.name, data.user3.mnemonic)?
	assert created.address != ""
	assets := client.algorand_assets_by_address(created.address)?
	assert assets.amount == 0
	assert assets.asset == ''
}

fn test_http_algorand_init_pop_account()? {
	// initialize bob account
	mut client, data := setup_http_algorand_tests()?
	assert data.user2.mnemonic != ""
	client.algorand_init(data.user2.name, data.user2.mnemonic) or {
		assert err.msg() == "A wallet with the same name $data.user2.name already exists"
		return
	}
}

fn test_http_algorand_list_accounts()? {
	// List [] => there are 3 algorand accounts.
	mut client, data := setup_http_algorand_tests()?
	algorand_accounts := client.algorand_list()?
	assert algorand_accounts.len == 3
}

fn test_http_algorand_delete_baz_account()? {
	// Delete alice account.
	mut client, data := setup_http_algorand_tests()?
	deleted := client.algorand_delete(data.user3.name)?
	assert deleted == true
}

fn test_http_algorand_delete_alice_account()? {
	// Delete alice account.
	mut client, data := setup_http_algorand_tests()?
	deleted := client.algorand_delete(data.user1.name)?
	assert deleted == true
}

fn test_http_algorand_delete_bob_account()? {
	// Delete bob account.
	mut client, data := setup_http_algorand_tests()?
	deleted := client.algorand_delete(data.user2.name)?
	assert deleted == true
}


// Issues above
// fn test_http_algorand_assets_for_alice()? {
// 	// Delete bob account.
// 	mut client, data := setup_http_algorand_tests()?
// 	deleted := client.algorand_assets(data.user1.name)?
// 	// assert deleted == true
// }

// fn test_http_algorand_account_exist()? {
// 	println('--------- Check if algorand account exist ---------')
// 	// There are no algorand accounts
// 	mut client, data := setup_http_algorand_tests()?
// 	exist := client.algorand_exist(data.user1.name)?
// 	assert exist == false
// }

// fn test_algorand_alice_pay_to_bob()? {
// 	// test pay for bob from alice.
// 	mut client, data := setup_http_algorand_tests()?
// 	deleted := client.algorand_delete(data.user2.name)? // Bob
// 	created := client.algorand_init(data.user2.name, data.user2.mnemonic)?
// 	assert created.address != ""
// 	paid := client.algorand_pay(
// 		data.user1.name, created.address, 1, "Is Paid?"
// 	)?

// }