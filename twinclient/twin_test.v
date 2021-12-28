module twinclient

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

// pub fn test_create_twin() {
// 	mut client, data := setup_twin_test()
// 	println('--------- Create Twin ---------')
// 	new_twin := client.create_twin(data.new_twin_ip) or { panic(err) }
// 	assert new_twin.ip == new_twin_ip
// 	println(new_twin)
// }

pub fn test_get_twin() {
	mut client, data := setup_twin_test()
	println('--------- Get Twin ---------')
	twin := client.get_twin(data.my_twin_id) or { panic(err) }
	assert twin.account_id == data.account_id
	println('Twin:: $twin')
}

pub fn test_get_twin_by_account_id() {
	mut client, data := setup_twin_test()
	println('--------- Get Twin Id By Account Id ---------')
	twin_id := client.get_twin_id_by_account_id(data.account_id) or { panic(err) }
	assert twin_id == data.my_twin_id
	println('Twin ID:: $twin_id')
}

pub fn test_get_my_twin() {
	mut client, data := setup_twin_test()
	println('--------- Get My Twin ---------')
	my_twin_id := client.get_my_twin_id() or { panic(err) }
	assert my_twin_id == data.my_twin_id
	println('My Twin ID:: $my_twin_id')
}

pub fn test_list_twin() {
	mut client, _ := setup_twin_test()
	println('--------- List Twin ---------')
	twins := client.list_twins() or { panic(err) }
	assert twins != []Twin{}
	println('Found $twins.len twins')
}

/*
// TAKE CARE, YOUR TWIN WILL BE DELETED HERE
// COMMENT THIS PART IF YOU DON'T WANT TO DELETE IT
pub fn test_delete_twin{
	mut client, data := setup_twin_test()
	println('--------- Delete Twin ---------')
	deleted_twin_id := client.delete_twin(data.twin_id_to_delete) or { panic(err) }
	println('Twin [$deleted_twin_id] deleted')
}
*/
