module openrpc

import freeflowuniverse.crystallib.baobab.actors.scheduler
import os

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'scheduler_test_actor'

//
pub fn testsuite_begin() {
	if os.exists('${db_dir}/${actor_name}') {
		os.rmdir_all('${db_dir}/${actor_name}')!
	}
	if os.exists('${db_dir}/${actor_name}.sqlite') {
		os.rm('${db_dir}/${actor_name}.sqlite')!
	}
}

//
pub fn testsuite_end() {
	if os.exists('${db_dir}/${actor_name}') {
		os.rmdir_all('${db_dir}/${actor_name}')!
	}
	if os.exists('${db_dir}/${actor_name}.sqlite') {
		os.rm('${db_dir}/${actor_name}.sqlite')!
	}
}

const rpc_json = ''

// handle handles an incoming JSON-RPC encoded message and returns an encoded response
fn test_handle() ! {

	mut handler := SchedulerHandler {scheduler.get(name: actor_name)!}
	response := handler.handle(rpc_json)!
}
