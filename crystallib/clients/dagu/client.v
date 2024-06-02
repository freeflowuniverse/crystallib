module dagu

import json
import freeflowuniverse.crystallib.clients.httpconnection

struct CreateDag {
	action string = 'new' @[required]
	value  string @[required]
}

struct CreateDagResponse {
	dag_id string = 'new' @[json: 'DagID'; required]
}

fn (mut cl DaguClient[Config]) set_http_connection() ! {
	cfg := cl.config_get()!
	if cl.connection.base_url != '${cfg.url}/api/v1' {
		mut con := httpconnection.new(
			name: 'dagu'
			url: '${cfg.url}/api/v1'
		)!
		con.basic_auth(cfg.username, cfg.password)
		cl.connection = con
	}
}

// Creates a new DAG.
pub fn (mut client DaguClient[Config]) create_dag(name string) !CreateDagResponse {
	request := httpconnection.new_request(
		method: .post
		prefix: 'dags'
		data: json.encode(CreateDag{ action: 'new', value: name })
	)!

	result := client.connection.send(request)!
	if !result.is_ok() {
		err := json.decode(ApiError, result.data)!
		return ApiError{
			...err
			code: result.code
		}
	}

	response := json.decode(CreateDagResponse, result.data)!
	return response
}

pub struct ListDagsResponse {
pub:
	dags      []DagListItem @[json: 'DAGs'; required]
	errors    []string      @[json: 'Errors'; required]
	has_error bool          @[json: 'HasError'; required]
}

pub struct DagListItem {
pub:
	file      string    @[json: 'File']
	dir       string    @[json: 'Dir']
	dag       DAG       @[json: 'DAG']
	status    DagStatus @[json: 'Status']
	suspended bool      @[json: 'Suspended']
	error     string    @[json: 'Error']
	error_t   string    @[json: 'ErrorT']
}

// pub struct DAG {
// pub:
// 	group          string     @[json: 'Group']
// 	name           string     @[json: 'Name']
// 	schedule       []Schedule @[json: 'Schedule']
// 	description    string     @[json: 'Description']
// 	params         []string   @[json: 'Params']
// 	default_params string     @[json: 'DefaultParams']
// 	tags           []string   @[json: 'Tags']
// }

pub struct Schedule {
	expression string @[json: 'Expression']
}

pub struct DagStatus {
	request_id  string @[json: 'RequestID']
	name        string @[json: 'Name']
	status      int    @[json: 'Status']
	status_text string @[json: 'StatusText']
	pid         int    @[json: 'PID']
	started_at  string @[json: 'StartedAt']
	finished_at string @[json: 'FinishedAt']
	log         string @[json: 'Log']
	params      string @[json: 'Params']
}

// Creates a new DAG.
pub fn (mut client DaguClient[Config]) list_dags() !ListDagsResponse {
	client.set_http_connection()!
	request := httpconnection.new_request(
		method: .get
		prefix: 'dags'
	)!

	result := client.connection.send(request)!
	if !result.is_ok() {
		err := json.decode(ApiError, result.data)!
		return ApiError{
			...err
			code: result.code
		}
	}

	response := json.decode(ListDagsResponse, result.data)!
	return response
}

@[params]
pub struct PostDagAction {
	action     DagAction @[required]
	value      string
	request_id string
	step       string
	params     string
}

enum DagAction {
	start
	suspend
	stop
	retry
	mark_success
	mark_failed
	save
	rename
}

pub struct PostDagActionResponse {
	new_dag_id string @[json: 'NewDagID']
}

pub fn (mut client DaguClient[Config]) post_dag_action(dag_id string, params PostDagAction) !PostDagActionResponse {
	client.set_http_connection()!
	request := httpconnection.new_request(
		method: .post
		prefix: 'dags/${dag_id}'
		data: json.encode(params)
	)!

	result := client.connection.send(request)!
	if !result.is_ok() {
		err := json.decode(ApiError, result.data)!
		return ApiError{
			...err
			code: result.code
		}
	}

	response := json.decode(PostDagActionResponse, result.data)!
	return response
}

pub fn (mut client DaguClient[Config]) delete_dag(dag_id string) ! {
	client.set_http_connection()!
	request := httpconnection.new_request(
		method: .delete
		prefix: 'dags/${dag_id}'
	)!

	result := client.connection.send(request)!
	if !result.is_ok() {
		err := json.decode(ApiError, result.data)!
		return ApiError{
			...err
			code: result.code
		}
	}
}
