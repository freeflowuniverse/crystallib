module daguclient

import time
import freeflowuniverse.crystallib.osal.dagu as dagu_osal
import freeflowuniverse.crystallib.clients.httpconnection

const username = 'test_username'
const password = 'test_password'

__global (
	client DaguClient
)

fn testsuite_begin() {
	client = new(
		username: dagu.username
		password: dagu.password
	)!

	mut d := dagu_osal.new()!
	d.basic_auth(dagu.username, dagu.password) or { panic(err) }
}

fn testsuite_end() {
	mut d := dagu_osal.new()!
	d.dag_delete('test_dag')!
}

fn test_create_dag() ! {
	response := client.create_dag('test_dag')!
	assert response == CreateDagResponse{
		dag_id: 'test_dag'
	}
}

fn test_dags_list() ! {
	response := client.dags_list()!
}

fn test_delete_dag() ! {
	mut error := false
	client.dag_delete(@FN) or { error = true }
	assert error

	client.create_dag(@FN)!
	client.dag_delete(@FN)!
}
