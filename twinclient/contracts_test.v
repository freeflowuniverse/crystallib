module twinclient

struct ContractTestData {
	twin_id           u32
	address           string
	new_node_contract NodeContractCreate
	new_name_contract string
	modified_hash     string
mut:
	created_node_contract_id            u64
	created_name_contract_id            u64
	get_contract_id_by_node_id_and_hash ContractIdByNodeIdAndHash
}

fn setup_contracts_test() (Client, ContractTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_contracts_test with error: $err')
	}

	mut data := ContractTestData{
		new_node_contract: NodeContractCreate{
			node_id: 5
			hash: '58cf017a18520fc478b2bc28123088e4'
			data: ''
			public_ip: 0
		}
		get_contract_id_by_node_id_and_hash: ContractIdByNodeIdAndHash{
			node_id: 5
			hash: '58cf017a18520fc478b2bc28123088e4'
		}
		new_name_contract: 'essam73'
		twin_id: 73
		address: '5Fk18xUkcFLTtURxa2aXb4SrLiHJoZEBt3McjbNERwSo548Q'
		modified_hash: '96e3227c5f19f482b0b2fb21074832a1'
	}

	return client, data
}

fn t0_create_node_contract(mut client Client, mut data ContractTestData) {
	println('--------- Create Node Contract ---------')
	node_contract := client.create_node_contract(data.new_node_contract) or {
		panic("Can't create new contract with error: $err")
	}
	data.created_node_contract_id = node_contract.contract_id
	println(node_contract)
}

fn t1_create_name_contract(mut client Client, mut data ContractTestData) {
	println('--------- Create Name Contract ---------')
	name_contract := client.create_name_contract(data.new_name_contract) or {
		panic("Can't create new contract with error: $err")
	}
	data.created_name_contract_id = name_contract.contract_id
	println(name_contract)
}

fn t2_get_contract(mut client Client, data ContractTestData) {
	println('--------- Get Contract ---------')
	mut get_contract := client.get_contract(data.created_node_contract_id) or {
		panic(err)
	}
	assert get_contract.twin_id == data.twin_id
	println(get_contract)
}

fn t3_update_contract(mut client Client, mut data ContractTestData) {
	println('--------- Update Contract ---------')
	mod_con := client.update_node_contract(
		id: data.created_node_contract_id
		hash: data.modified_hash
		data: ''
	) or { panic(err) }
	data.get_contract_id_by_node_id_and_hash.hash = data.modified_hash
	println(mod_con)
}

fn t4_get_contract_id_by_node_id_and_hash(mut client Client, data ContractTestData) {
	println('--------- Get Contract Id by Node Id and Hash ---------')
	mut get_contract := client.get_contract_id_by_node_and_hash(data.get_contract_id_by_node_id_and_hash) or {
		panic(err)
	}
	println(get_contract)
}

fn t5_get_name_contract(mut client Client, data ContractTestData) {
	println('--------- Get Name Contract ---------')
	mut get_contract := client.get_name_contract(data.new_name_contract) or { panic(err) }
	assert get_contract == data.created_name_contract_id
	println("Name contract id :: $get_contract")
}

fn t6_list_my_contracts(mut client Client, data ContractTestData) {
	println('--------- List My Contracts ---------')
	mut my_contracts := client.list_my_contracts() or { panic(err) }
	println(my_contracts)
}

fn t7_list_contracts_by_twin_id(mut client Client, data ContractTestData) {
	println('--------- List Contracts By TwinId ---------')
	mut contracts := client.list_contracts_by_twin_id(data.twin_id) or { panic(err) }
	println(contracts)
}

fn t8_list_contracts_by_address(mut client Client, data ContractTestData) {
	println('--------- List Contracts By Address ---------')
	mut contracts := client.list_contracts_by_address(data.address) or { panic(err) }
	println(contracts)
}

fn t9_get_consumption(mut client Client, data ContractTestData) {
	println('--------- Get Contract Consumption ---------')
	mut consumption := client.get_consumption(data.created_node_contract_id) or {
		panic(err)
	}
	println(consumption)
}

fn t10_cancel_contract(mut client Client, data ContractTestData) {
	println('--------- Cancel Contract ---------')
	canceled_contract_id := client.cancel_contract(data.created_node_contract_id) or {
		panic(err)
	}
	assert canceled_contract_id == data.created_node_contract_id
	println('contract [$canceled_contract_id] cancelled')
}

fn t11_cancel_my_contracts(mut client Client, data ContractTestData) {
	println('--------- Cancel My Contracts ---------')
	cancel_my_contracts := client.cancel_my_contracts() or { panic(err) }
	println('contract [$cancel_my_contracts] cancelled')
}

pub fn test_contracts() {
	mut client, mut data := setup_contracts_test()
	t0_create_node_contract(mut client, mut data)
	t1_create_name_contract(mut client, mut data)
	t2_get_contract(mut client, data)
	t3_update_contract(mut client, mut data)
	t4_get_contract_id_by_node_id_and_hash(mut client, data)
	t5_get_name_contract(mut client, data)
	t6_list_my_contracts(mut client, data)
	t7_list_contracts_by_twin_id(mut client, data)
	t8_list_contracts_by_address(mut client, data)
	t9_get_consumption(mut client, data)
	t10_cancel_contract(mut client, data)
	// ATTENTION: DELETE ALL YOUR CONTRACTS!
	t11_cancel_my_contracts(mut client, data)
}
