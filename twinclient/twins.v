module twinclient

import json

// Create a new twin using your planetary ip or ipv6
pub fn (mut tw Client) create_twin(ip string) ?Twin {
	mut msg := tw.send('twinserver.twins.create', '{"ip": "$ip"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Twin, response.data) or {}
}

// Get twin info for specific twin id
pub fn (mut tw Client) get_twin(id u32) ?Twin {
	mut msg := tw.send('twinserver.twins.get', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Twin, response.data) or {}
}

// Get my twin id
pub fn (mut tw Client) get_my_twin_id() ?u32 {
	mut msg := tw.send('twinserver.twins.get_my_twin_id', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u32()
}

// Get twin id for from account id
pub fn (mut tw Client) get_twin_id_by_account_id(public_key string) ?u32 {
	mut msg := tw.send('twinserver.twins.get_twin_id_by_account_id', '{"public_key": "$public_key"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u32()
}

// List all twins
pub fn (mut tw Client) list_twins() ?[]Twin {
	mut msg := tw.send('twinserver.twins.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Twin, response.data) or {}
}

// Delete twin using twin_id
pub fn (mut tw Client) delete_twin(id u32) ?u32 {
	mut msg := tw.send('twinserver.twins.delete', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u32()
}
