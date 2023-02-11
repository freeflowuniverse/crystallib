module twinclient

import json
// Deploy zos workload

pub fn (mut client TwinClient) zos_deploy(payload string) !Contract {
	response := client.transport.send('zos.deploy', payload)!
	return json.decode(Contract, response.data)!
}

pub fn (mut client TwinClient) zos_get_node_statistics(node_id u32) !ZOSNodeStatisticsResponse{
	// ZOSGetDeployment
	data := ZOSGetDeployment{
		node_id: node_id
	}
	response := client.transport.send('zos.getNodeStatistics', json.encode(data).str())!
	return json.decode(ZOSNodeStatisticsResponse, response.data)!
}

pub fn (mut client TwinClient) zos_ping_node(node_id u32) !Message{
	// ZOSGetDeployment
	data := ZOSGetDeployment{
		node_id: node_id
	}
	response := client.transport.send('zos.pingNode', json.encode(data).str())!
	return response
}
