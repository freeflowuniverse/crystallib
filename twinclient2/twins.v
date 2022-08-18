module twinclient2

import json

// Create a new twin using your planetary ip or ipv6
pub fn (mut tw TwinClient) create_twin(ip string) ?Twin {
	response := tw.send('twins.create', '{"ip": "$ip"}')?
	return json.decode(Twin, response.data) or {}
}

// Get twin info for specific twin id
pub fn (mut tw TwinClient) get_twin(id u32) ?Twin {
	response := tw.send('twins.get', '{"id": $id}')?
	return json.decode(Twin, response.data) or {}
}

// Get my twin id
pub fn (mut tw TwinClient) get_my_twin_id() ?u32 {
	response := tw.send('twins.get_my_twin_id', '{}')?
	return response.data.u32()
}

// Get twin id for from account id
pub fn (mut tw TwinClient) get_twin_id_by_account_id(public_key string) ?u32 {
	response := tw.send('twins.get_twin_id_by_account_id', '{"public_key": "$public_key"}')?
	return response.data.u32()
}

// List all twins
pub fn (mut tw TwinClient) list_twins() ?[]Twin {
	response := tw.send('twins.list', '{}')?
	return json.decode([]Twin, response.data) or {}
}

// Delete twin using twin_id
pub fn (mut tw TwinClient) delete_twin(id u32) ?u32 {
	response := tw.send('twins.delete', '{"id": $id}')?
	return response.data.u32()
}
