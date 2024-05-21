module scheduler

import baobab.seeds.schedule
import freeflowuniverse.crystallib.rpc.jsonrpc { new_jsonrpcrequest }
import os

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'scheduler_test_actor'

pub fn testsuite_begin() {
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}') {
		os.rmdir_all('${scheduler.db_dir}/${scheduler.actor_name}')!
	}
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}.sqlite') {
		os.rm('${scheduler.db_dir}/${scheduler.actor_name}.sqlite')!
	}
}

pub fn testsuite_end() {
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}') {
		os.rmdir_all('${scheduler.db_dir}/${scheduler.actor_name}')!
	}
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}.sqlite') {
		os.rm('${scheduler.db_dir}/${scheduler.actor_name}.sqlite')!
	}
}

pub fn test_handle_get_calendar() ! {
	mut handler := SchedulerHandler{get(name: scheduler.actor_name)!}
	request := new_jsonrpcrequest[string]('get_calendar', 'mock_string_vto')
	response_json := handler.handle(request.to_json())!
}

pub fn test_handle_delete_calendar() ! {
	mut handler := SchedulerHandler{get(name: scheduler.actor_name)!}
	request := new_jsonrpcrequest[string]('delete_calendar', 'mock_string_CFj')
	response_json := handler.handle(request.to_json())!
}
