module dagu

import json
import freeflowuniverse.crystallib.clients.httpconnection

struct CreateDag {
	action string = 'new' @[required]
	value string @[required]
}

struct CreateDagResponse {
	dag_id string = 'new' @[required; json: 'DagID']
}

// Creates a new DAG.
pub fn (mut client DaguClient) create_dag(name string) !CreateDagResponse {
	request := httpconnection.new_request(
		method: .post
		prefix: 'dags'
		data:json.encode(CreateDag{action:'new', value: name})
	)!

	result := client.connection.send(request)!
	if !result.is_ok() {
		return error('${@FN} failed: ${result}')
	}

	response := json.decode(CreateDagResponse, result.data)!
	return response
}