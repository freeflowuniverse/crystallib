module dagu

import time
import freeflowuniverse.crystallib.osal.dagu as dagu_osal
import freeflowuniverse.crystallib.clients.httpconnection

const (
	username = 'test_username'
	password = 'test_password'
)

__global(
	client DaguClient
)

fn testsuite_begin() {
	client = new(
		username: username
		password: password
	)!

	mut d := dagu_osal.new()!
	d.basic_auth(username, password) or {panic(err)}
}

fn testsuite_end() {
	mut d := dagu_osal.new()!
	d.delete_dag('test_dag')!
}

fn test_create_dag() ! {
	response := client.create_dag('test_dag')!
	assert response == CreateDagResponse{dag_id:'test_dag'}
}

fn test_list_dags() ! {
	response := client.list_dags()!
}

fn test_delete_dag() ! {
	mut error := false
	client.delete_dag(@FN) or {error = true}
	assert error
	
	client.create_dag(@FN)!
	client.delete_dag(@FN)!
}