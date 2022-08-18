module twinclient2

import json

pub fn (mut tw TwinClient) get_farms(payload PagePayload) ?[]Farm {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('capacity.getFarms', payload_encoded)?
	return json.decode([]Farm, response.data) or {}
}

pub fn (mut tw TwinClient) get_nodes(payload PagePayload) ?[]Node {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('capacity.getNodes', payload_encoded)?
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw TwinClient) get_all_farms() ?[]Farm {
	response := tw.send('capacity.getAllFarms', '{}')?
	return json.decode([]Farm, response.data) or {}
}

pub fn (mut tw TwinClient) get_all_nodes() ?[]Node {
	response := tw.send('capacity.getAllNodes', '{}')?
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw TwinClient) filter_nodes(filters FilterOptions) ?[]Node {
	payload_encoded := json.encode_pretty(filters)
	response := tw.send('capacity.filterNodes', payload_encoded)?
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw TwinClient) check_farm_has_free_public_ips(farm_id u32) ?bool {
	response := tw.send('capacity.checkFarmHasFreePublicIps', '{"farmId": $farm_id}')?
	return response.data.bool()
}

pub fn (mut tw TwinClient) get_nodes_by_farm_id(farm_id u32) ?[]Node {
	response := tw.send('capacity.getNodesByFarmId', '{"farmId": $farm_id}')?
	return json.decode([]Node, response.data) or {}
}

pub fn (mut tw TwinClient) get_node_free_resources(node_id u32) ?FreeResources {
	response := tw.send('capacity.getNodeFreeResources', '{"nodeId": $node_id}')?
	return json.decode(FreeResources, response.data) or {}
}

pub fn (mut tw TwinClient) get_farm_id_from_farm_name(farm_name string) ?u32 {
	response := tw.send('capacity.getFarmIdFromFarmName', '{"farmName": "$farm_name"}')?
	return response.data.u32()
}
