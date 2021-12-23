module twinclient

pub fn test_contract() {
	// redis_server and twin_dest are const in client.v
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Create new contract
	node_id := u32(5) // CHOOSE THE NODE ID YOU WANT.
	hash := '58cf017a18520fc478b2bc28123088e4' // ADD YOUR HASH HERE.
	data := '' // ADD NEEDED DATA HERE, Let it empty for default.
	public_ip := u32(0)
	println('--------- Create Contract ---------')
	new_contract := tw.create_node_contract(node_id, hash, data, public_ip) or {
		panic("Can't create new contract with error: $err")
	}
	println(new_contract)

	// Get Contract
	println('--------- Get Contract ---------')
	mut get_contract := tw.get_contract(new_contract.contract_id) or { panic(err) }
	assert get_contract.twin_id == twin_dest
	println(get_contract)

	// Upgrade Contract
	mod_contract_id := new_contract.contract_id
	mod_hash := '96e3227c5f19f482b0b2fb21074832a1' // ADD YOUR HASH HERE.
	mod_data := '' // ADD NEEDED DATA HERE, Let it empty for default.
	println('--------- Update Contract ---------')
	mod_con := tw.update_node_contract(mod_contract_id, mod_hash, mod_data) or { panic(err) }
	println(mod_con)

	// Cancel Contract
	// TAKE CARE, YOUR CONTRACT WILL BE CANCELED HERE
	// COMMENT THIS PART IF YOU DON'T WANT TO CANCEL IT
	println('--------- Cancel Contract ---------')
	canceled_contract_id := tw.cancel_contract(new_contract.contract_id) or { panic(err) }
	assert canceled_contract_id == new_contract.contract_id
	println('contract [$canceled_contract_id] cancelled')

	// List My Contracts
	println('--------- List Contracts ---------')
	start := u64(1) // START FROM --> CONTRACT ID
	end := u64(20) // END AT -- > CONTRACT ID
	mut mycontracts := []Contract{}
	mut con := Contract{}
	for i in start .. end {
		con = tw.get_contract(i) or { panic(err) }
		if con.twin_id == twin_dest && con.state != 'Deleted' {
			mycontracts << con
			println(con)
		}
	}

	// Cancel list of Contract
	// TAKE CARE, YOUR CONTRACT WILL BE CANCELED HERE
	// COMMENT THIS PART IF YOU DON'T WANT TO CANCEL IT
	println('--------- Cancel list Contract ---------')
	for c in mycontracts {
		canceled_con_id := tw.cancel_contract(c.contract_id) or { panic(err) }
		println('contract [$canceled_con_id] cancelled')
	}
}
