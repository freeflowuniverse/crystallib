module dagu

import time
import freeflowuniverse.crystallib.osal.dagu as dagu_osal
import freeflowuniverse.crystallib.clients.httpconnection

const (
	username = 'test_username'
	password = 'test_password'
)

fn testsuite_begin() {
	mut d := dagu_osal.new()!
	d.basic_auth(username, password)!
}

fn testsuite_end() {
	mut d := dagu_osal.new()!
	d.delete_dag('test_dag')!
}

fn test_create_dag() ! {
	// spawn dagu_osal.server()
	mut client := new(
		username: username
		password: password
	)!
	response := client.create_dag('test_dag')!
	assert response == CreateDagResponse{dag_id:'test_dag'}
}