module dagu

import json
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.osal.dagu {DAG}

pub fn (mut client DaguClient) new_dag(dag DAG) !PostDagActionResponse {
	client.create_dag(dag.name)!
	return client.edit_dag(dag.name, dag)!
}

pub fn (mut client DaguClient) edit_dag(name string, dag DAG) !PostDagActionResponse {
	println('dag ${json.encode(dag)}')
	return client.post_dag_action(
		name, 
		action: .save
		value: json.encode(dag)
	) or {return error('Failed to edit dag: ${err}')}
}

pub fn (mut client DaguClient) start_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .start)!
}

pub fn (mut client DaguClient) stop_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .stop)!
}

pub fn (mut client DaguClient) suspend_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .suspend)!
}