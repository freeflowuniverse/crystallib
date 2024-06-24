module dagu

import json
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct NewDagOptions {
pub:
	overwrite bool // whether to overwrite existing dag with same name
}

pub fn (mut client DaguClient[Config]) new_dag(dag DAG, opts NewDagOptions) !PostDagActionResponse {
	if opts.overwrite {
		dag_list := client.list_dags()!
		if dag_list.dags.any(it.dag.name == dag.name) {
			client.delete_dag(dag.name)!
		}
	}

	client.create_dag(dag.name)!
	return client.edit_dag(dag.name, dag)!
}

pub fn (mut client DaguClient[Config]) edit_dag(name string, dag DAG) !PostDagActionResponse {
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
