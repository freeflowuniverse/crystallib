module twinclient2

import json



fn new_capacity(mut client TwinClient) Capacity {
	// Initialize new tfchain.
	return Capacity{
		client: unsafe {client}
	}
}

pub fn (mut cps Capacity) get_farms(payload PagePayload) ?[]Farm {
	payload_encoded := json.encode_pretty(payload)
	response := cps.client.send('capacity.getFarms', payload_encoded)?
	return json.decode([]Farm, response.data)
}

pub fn (mut cps Capacity) get_nodes(payload PagePayload) ?[]Node {
	payload_encoded := json.encode_pretty(payload)
	response := cps.client.send('capacity.getNodes', payload_encoded)?
	return json.decode([]Node, response.data)
}

pub fn (mut cps Capacity) get_all_farms() ?[]Farm {
	response := cps.client.send('capacity.getAllFarms', '{}')?
	return json.decode([]Farm, response.data)
}

pub fn (mut cps Capacity) get_all_nodes() ?[]Node {
	response := cps.client.send('capacity.getAllNodes', '{}')?
	return json.decode([]Node, response.data)
}

pub fn (mut cps Capacity) filter_nodes(filters FilterOptions) ?[]Node {
	payload_encoded := json.encode_pretty(filters)
	response := cps.client.send('capacity.filterNodes', payload_encoded)?
	return json.decode([]Node, response.data)
}

pub fn (mut cps Capacity) check_farm_has_free_public_ips(farm_id u32) ?bool {
	response := cps.client.send(
		'capacity.checkFarmHasFreePublicIps',
		json.encode({"farmId": farm_id})
	)?
	return response.data.bool()
}

pub fn (mut cps Capacity) get_nodes_by_farm_id(farm_id u32) ?[]Node {
	response := cps.client.send('capacity.getNodesByFarmId', json.encode({"farmId": farm_id}))?
	return json.decode([]Node, response.data)
}

pub fn (mut cps Capacity) get_node_free_resources(node_id u32) ?FreeResources {
	response := cps.client.send(
		'capacity.getNodeFreeResources',
		json.encode({"nodeId": node_id})
	)?
	return json.decode(FreeResources, response.data)
}

pub fn (mut cps Capacity) get_farm_id_from_farm_name(farm_name string) ?u32 {
	response := cps.client.send(
		'capacity.getFarmIdFromFarmName',
		json.encode({"farmName": "$farm_name"})
	)?
	return response.data.u32()
}
