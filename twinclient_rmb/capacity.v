module twinclient

import json

pub fn (mut tw Client) get_farms(payload PagePayload) ?[]Farm {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.capacity.getFarms', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Farm, response.data) or {}
}

pub fn (mut tw Client) get_nodes(payload PagePayload) ?[]Node {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.capacity.getNodes', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw Client) get_all_farms() ?[]Farm {
	mut msg := tw.send('twinserver.capacity.getAllFarms', '{}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Farm, response.data) or {}
}

pub fn (mut tw Client) get_all_nodes() ?[]Node {
	mut msg := tw.send('twinserver.capacity.getAllNodes', '{}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw Client) filter_nodes(filters FilterOptions) ?[]Node {
	payload_encoded := json.encode_pretty(filters)
	mut msg := tw.send('twinserver.capacity.filterNodes', payload_encoded)?
	response := tw.read(msg)
	if response.err.contains("Couldn't find a valid node for these options") {
		return []Node{}
	}
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw Client) check_farm_has_free_public_ips(farm_id u32) ?bool {
	mut msg := tw.send('twinserver.capacity.checkFarmHasFreePublicIps', '{"farmId": $farm_id}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.bool()
}

pub fn (mut tw Client) get_nodes_by_farm_id(farm_id u32) ?[]Node {
	mut msg := tw.send('twinserver.capacity.getNodesByFarmId', '{"farmId": $farm_id}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw Client) get_node_free_resources(node_id u32) ?FreeResources {
	mut msg := tw.send('twinserver.capacity.getNodeFreeResources', '{"nodeId": $node_id}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(FreeResources, response.data) or {}
}

pub fn (mut tw Client) get_farm_id_from_farm_name(farm_name string) ?u32 {
	mut msg := tw.send('twinserver.capacity.getFarmIdFromFarmName', '{"farmName": "$farm_name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u32()
}
