module twinclient2

import json

pub fn (mut client TwinClient) capacity_get_farms(payload PagePayload) ?[]Farm {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('capacity.getFarms', payload_encoded)?
	return json.decode([]Farm, response.data)
}

pub fn (mut client TwinClient) capacity_get_nodes(payload PagePayload) ?[]Node {
	payload_encoded := json.encode_pretty(payload)
	response := client.send('capacity.getNodes', payload_encoded)?
	return json.decode([]Node, response.data)
}

pub fn (mut client TwinClient) capacity_get_all_farms() ?[]Farm {
	response := client.send('capacity.getAllFarms', '{}')?
	return json.decode([]Farm, response.data)
}

pub fn (mut client TwinClient) capacity_get_all_nodes() ?[]Node {
	response := client.send('capacity.getAllNodes', '{}')?
	return json.decode([]Node, response.data)
}

pub fn (mut client TwinClient) capacity_filter_nodes(filters FilterOptions) ?[]Node {
	payload_encoded := json.encode_pretty(filters)
	response := client.send('capacity.filterNodes', payload_encoded)?
	return json.decode([]Node, response.data)
}

pub fn (mut client TwinClient) capacity_check_farm_has_free_public_ips(farm_id u32) ?bool {
	response := client.send('capacity.checkFarmHasFreePublicIps', json.encode({
		'farmId': farm_id
	}))?
	return response.data.bool()
}

pub fn (mut client TwinClient) capacity_get_nodes_by_farm_id(farm_id u32) ?[]Node {
	response := client.send('capacity.getNodesByFarmId', json.encode({
		'farmId': farm_id
	}))?
	return json.decode([]Node, response.data)
}

pub fn (mut client TwinClient) capacity_get_node_free_resources(node_id u32) ?FreeResources {
	response := client.send('capacity.getNodeFreeResources', json.encode({
		'nodeId': node_id
	}))?
	return json.decode(FreeResources, response.data)
}

pub fn (mut client TwinClient) capacity_get_farm_id_from_farm_name(farm_name string) ?u32 {
	response := client.send('capacity.getFarmIdFromFarmName', json.encode({
		'farmName': '$farm_name'
	}))?
	return response.data.u32()
}
