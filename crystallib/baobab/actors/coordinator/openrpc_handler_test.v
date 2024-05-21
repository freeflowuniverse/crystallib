module coordinator

import baobab.seeds.project
import freeflowuniverse.crystallib.rpc.jsonrpc { new_jsonrpcrequest }
import os

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'coordinator_test_actor'

pub fn testsuite_begin() {
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}') {
		os.rmdir_all('${coordinator.db_dir}/${coordinator.actor_name}')!
	}
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}.sqlite') {
		os.rm('${coordinator.db_dir}/${coordinator.actor_name}.sqlite')!
	}
}

pub fn testsuite_end() {
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}') {
		os.rmdir_all('${coordinator.db_dir}/${coordinator.actor_name}')!
	}
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}.sqlite') {
		os.rm('${coordinator.db_dir}/${coordinator.actor_name}.sqlite')!
	}
}

pub fn test_handle_get_story() ! {
	mut handler := CoordinatorHandler{get(name: coordinator.actor_name)!}
	request := new_jsonrpcrequest[string]('get_story', 'mock_string_ceC')
	response_json := handler.handle(request.to_json())!
}

pub fn test_handle_delete_story() ! {
	mut handler := CoordinatorHandler{get(name: coordinator.actor_name)!}
	request := new_jsonrpcrequest[string]('delete_story', 'mock_string_DnT')
	response_json := handler.handle(request.to_json())!
}
