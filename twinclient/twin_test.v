module twinclient

pub fn test_twin() {
	mut twin_dest := 49 // ADD TWIN ID.
	mut tw := init(redis_server, twin_dest) or { panic(err) }

	// Create new twin
	new_twin_ip := 'ADD_YOUR_IPV6 ADDRESS HERE'
	println('--------- Create Twin ---------')
	new_twin := tw.create_twin(new_twin_ip) or { panic(err) }
	assert new_twin.ip == new_twin_ip
	println(new_twin)

	// Get twin
	println('--------- Get Twin ---------')
	twin_49 := tw.get_twin(49) or { panic(err) }
	assert twin_49.account_id == '5D2etsCt37ucdTvybV8PaeQzmoUsNp7RzxZQGJosmY8PUvKQ'
	println(twin_49)

	// List twins
	println('--------- List Twin ---------')
	twins := tw.list_twins() or { panic(err) }
	assert twins != []Twin{}
	println('Found $twins.len twins')
	println(twins)

	// Delete Twin
	// TAKE CARE, YOUR TWIN WILL BE DELETED HERE
	// COMMENT THIS PART IF YOU DON'T WANT TO DELETE IT
	println('--------- Delete Twin ---------')
	deleted_twin_id := tw.delete_twin(new_twin.id)
	println('Twin [$deleted_twin_id] deleted')
}
