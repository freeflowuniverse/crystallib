module dagu

import json
import freeflowuniverse.crystallib.ui.console

pub fn (mut client DaguClient[Config]) new_dag(dag DAG) !PostDagActionResponse {
	client.create_dag(dag.name)!
	return client.edit_dag(dag.name, dag)!
}

pub fn (mut client DaguClient[Config]) edit_dag(name string, dag DAG) !PostDagActionResponse {
	console.print_debug('dag ${json.encode(dag)}')
	return client.post_dag_action(name,
		action: .save
		value: json.encode(dag)
	) or { return error('Failed to edit dag: ${err}') }
}

pub fn (mut client DaguClient[Config]) start_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .start)!
}

pub fn (mut client DaguClient[Config]) stop_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .stop)!
}

pub fn (mut client DaguClient[Config]) suspend_dag(name string) !PostDagActionResponse {
	return client.post_dag_action(name, action: .suspend)!
}
