module twinclient

fn setup_balance_test() (Client, BalanceTransfer) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_balance_test with error: $err')
	}
	data := BalanceTransfer{
		address: '5D2etsCt37ucdTvybV8PaeQzmoUsNp7RzxZQGJosmY8PUvKQ'
		amount: 1
	}
	return client, data
}

pub fn test_get_balance() {
	mut client, data := setup_balance_test()
	println('--------- Get Balance ---------')
	balance := client.get_balance(data.address) or { panic(err) }
	println(balance)
}

pub fn test_get_my_balance() {
	mut client, _ := setup_balance_test()
	println('--------- Get MyBalance ---------')
	myBalance := client.get_my_balance() or { panic(err) }
	println(myBalance)
}

pub fn test_transfer_balance() {
	mut client, data := setup_balance_test()
	println('--------- Transfer Balance ---------')
	client.transfer_balance(data) or { panic(err) }
}
