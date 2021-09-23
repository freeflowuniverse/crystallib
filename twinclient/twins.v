module twinclient

import json

pub struct Twin {
pub:
	version    u32
	id         u32
	account_id string
	ip         string
	entities   []EntityProof
}

struct EntityProof {
	entity_id u32
	signature string
}

pub fn (mut tw Client) create_twin(ip string) ?Twin {
	/*
	Create a new twin
		Input:
			- ip: ipv6 address
		Output:
			- Twin: new twin instance with all twin info.
	*/

	mut msg := tw.send('twinserver.twins.create', '{"ip": "$ip"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Twin, response.data) or {}
}

pub fn (mut tw Client) get_twin(id u32) ?Twin {
	/*
	Get twin info using twin id
		Input:
			- id: twin id
		Output:
			- Twin: twin instance with all twin info.
	*/
	mut msg := tw.send('twinserver.twins.get', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Twin, response.data) or {}
}

pub fn (mut tw Client) list_twins() ?[]Twin {
	/*
	List all twins
		Output:
			- Twins: Array of all current twins.
	*/
	mut msg := tw.send('twinserver.twins.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]Twin, response.data) or {}
}

pub fn (mut tw Client) delete_twin(id u32) ?u32 {
	/*
	Delete twin
		Input:
			- id: twin id
		Output:
			- deleted id: return the deleted twin id
	*/
	mut msg := tw.send('twinserver.twins.delete', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return response.data.u32()
}
