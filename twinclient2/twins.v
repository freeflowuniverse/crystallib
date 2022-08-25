module twinclient2

import json



fn new_twins(mut client TwinClient) Twins {
	// Initialize new Twins.
	return Twins{
		client: unsafe {client}
	}
}

// Create a new twin using your planetary ip or ipv6
pub fn (mut tw Twins) create(ip string) ?TwinModel {
	response := tw.client.send('twins.create', json.encode({"ip": ip}))?
	return json.decode(TwinModel, response.data)
}

// Get twin info for specific twin id
pub fn (mut tw Twins) get(id u32) ?TwinModel {
	response := tw.client.send('twins.get', json.encode({"id": id}))?
	return json.decode(TwinModel, response.data)
}

// Get my twin id
pub fn (mut tw Twins) get_my_twin_id() ?u32 {
	response := tw.client.send('twins.get_my_twin_id', '{}')?
	return response.data.u32()
}

// Get twin id for from account id
pub fn (mut tw Twins) get_twin_id_by_account_id(public_key string) ?u32 {
	response := tw.client.send('twins.get_twin_id_by_account_id', json.encode({"public_key": public_key}))?
	return response.data.u32()
}

// List all twins
pub fn (mut tw Twins) list() ?[]TwinModel {
	response := tw.client.send('twins.list', '{}')?
	return json.decode([]TwinModel, response.data) or {}
}

// Delete twin using twin_id
pub fn (mut tw Twins) delete(id u32) ?u32 {
	response := tw.client.send('twins.delete', json.encode({"id": id}))?
	return response.data.u32()
}
