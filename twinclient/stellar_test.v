module twinclient
import os

fn prepare_src_wallet(mut twinclient Client) ?StellarWallet {
	src_wallet_secret := os.environ()['SOURCE_WALLET_SECRET']
	if src_wallet_secret == ''{
		panic('Please add your source wallet secret in SOURCE_WALLET_SECRET to import it')
	}
	src_wallet_name := "src_test_wallet"
	// Check if src wallet exists, get it, else import it.
	mut src_wallet := StellarWallet{}
	is_src_exist := twinclient.is_wallet_exist(src_wallet_name) or { panic(err) }
	if is_src_exist {
		// Get Wallet
		src_wallet = twinclient.get_wallet(src_wallet_name) or { panic(err) }
	}else{
		// Import Wallet
		src_wallet = twinclient.import_wallet(src_wallet_name, src_wallet_secret) or { panic(err) }
	}
	return src_wallet
}

pub fn test_stellar() {
	// redis_server and twin_dest are const in client.v
	mut tw := init(redis_server, twin_dest) or { panic(err) }
	src_wallet := prepare_src_wallet(mut tw) or { panic(err) }
	
	//Use env variable to pass the wallet secret
	wallet_secret := os.environ()['WALLET_SECRET']
	if wallet_secret == ''{
		panic('Please add your wallet secret in WALLET_SECRET to import it')
	}
	wallet_name := "twin_test_walllet"
	// Check if wallet exists, get it, else import it.
	mut wallet := StellarWallet{}
	is_exist := tw.is_wallet_exist(wallet_name) or { panic(err) }
	if is_exist {
		// Get Wallet
		println('--------- Get Wallet ---------')
		wallet = tw.get_wallet(wallet_name) or { panic(err) }
	}else{
		// Import Wallet
		println('--------- Import Wallet ---------')
		wallet = tw.import_wallet(wallet_name, wallet_secret) or { panic(err) }
	}
	assert wallet.address != ""
	println(wallet)

	// List wallets
	println('--------- List Wallets ---------')
	all_wallets := tw.list_wallets() or { panic(err) }
	assert wallet_name in all_wallets
	println(all_wallets)
	
	// get balance by wallet name
	println('--------- Balance By Wallet Name ---------')
	balance_by_name :=  tw.balance_by_name(wallet.name) or { panic(err) }
	println(balance_by_name)

	// get balance by wallet address
	println('--------- Balance By Wallet Address ---------')
	balance_by_address := tw.balance_by_address(wallet.address) or { panic(err) }
	println(balance_by_name)

	// transfer
	println('--------- Transfer ---------')
	transfer_link := tw.transfer(src_wallet.name, wallet.name, 'TFT', 0.1, '') or { panic(err) }
	transfer_back := tw.transfer(wallet.name, src_wallet.address, 'TFT', 0.09, '') or { panic(err) }
	
	// Update
	new_secret := os.environ()['UPDATE_WALLET_SECRET']
	if new_secret == ''{
		panic('Please add your updated wallet secret in UPDATE_WALLET_SECRET to update it')
	}
	println('--------- Update Wallet Secret ---------')
	updated_wallet := tw.update_wallet(wallet.name, new_secret) or { panic(err) }

	// delete wallet
	delete_wallet := tw.delete_wallet(wallet_name) or {panic(err)}
	assert delete_wallet
	println("$wallet_name Deleted")
}