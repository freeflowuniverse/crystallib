module accountant

import baobab.seeds.finance
import freeflowuniverse.crystallib.rpc.jsonrpc { new_jsonrpcrequest }
import os

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'accountant_test_actor'

pub fn testsuite_begin() {
	if os.exists('${accountant.db_dir}/${accountant.actor_name}') {
		os.rmdir_all('${accountant.db_dir}/${accountant.actor_name}')!
	}
	if os.exists('${accountant.db_dir}/${accountant.actor_name}.sqlite') {
		os.rm('${accountant.db_dir}/${accountant.actor_name}.sqlite')!
	}
}

pub fn testsuite_end() {
	if os.exists('${accountant.db_dir}/${accountant.actor_name}') {
		os.rmdir_all('${accountant.db_dir}/${accountant.actor_name}')!
	}
	if os.exists('${accountant.db_dir}/${accountant.actor_name}.sqlite') {
		os.rm('${accountant.db_dir}/${accountant.actor_name}.sqlite')!
	}
}

pub fn test_handle_get_budget() ! {
	mut handler := AccountantHandler{get(name: accountant.actor_name)!}
	request := new_jsonrpcrequest[string]('get_budget', 'mock_string_PDE')
	response_json := handler.handle(request.to_json())!
}

pub fn test_handle_delete_budget() ! {
	mut handler := AccountantHandler{get(name: accountant.actor_name)!}
	request := new_jsonrpcrequest[string]('delete_budget', 'mock_string_rfA')
	response_json := handler.handle(request.to_json())!
}
