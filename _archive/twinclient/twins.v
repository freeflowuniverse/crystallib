module twinclient

import json

// Create a new twin using your planetary ip or ipv6
pub fn (mut client TwinClient) twins_create(ip string) !TwinModel {
	response := client.transport.send('twins.create', json.encode({
		'ip': ip
	}))!
	return json.decode(TwinModel, response.data)
}

// Get twin info for specific twin id
pub fn (mut client TwinClient) twins_get(id u32) !TwinModel {
	response := client.transport.send('twins.get', json.encode({
		'id': id
	}))!
	return json.decode(TwinModel, response.data)
}

// Get my twin id
pub fn (mut client TwinClient) twins_get_my_twin_id() !u32 {
	response := client.transport.send('twins.get_my_twin_id', '{}')!
	return response.data.u32()
}

// Get twin id for from account id
pub fn (mut client TwinClient) twins_get_twin_id_by_account_id(public_key string) !u32 {
	response := client.transport.send('twins.get_twin_id_by_account_id', json.encode({
		'public_key': public_key
	}))!
	return response.data.u32()
}

// List all twins
pub fn (mut client TwinClient) twins_list() ![]TwinModel {
	response := client.transport.send('twins.list', '{}')!
	return json.decode([]TwinModel, response.data) or {}
}

// Delete twin using twin_id
pub fn (mut client TwinClient) twins_delete(id u32) !u32 {
	response := client.transport.send('twins.delete', json.encode({
		'id': id
	}))!
	return response.data.u32()
}
