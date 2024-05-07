module accountant

import os
import baobab.seeds.finance { Budget }

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'Accountant_test_actor'

//
pub fn testsuite_begin() {
	if os.exists('${accountant.db_dir}/${accountant.actor_name}') {
		os.rmdir_all('${accountant.db_dir}/${accountant.actor_name}')!
	}
	if os.exists('${accountant.db_dir}/${accountant.actor_name}.sqlite') {
		os.rm('${accountant.db_dir}/${accountant.actor_name}.sqlite')!
	}
}

//
pub fn testsuite_end() {
	if os.exists('${accountant.db_dir}/${accountant.actor_name}') {
		os.rmdir_all('${accountant.db_dir}/${accountant.actor_name}')!
	}
	if os.exists('${accountant.db_dir}/${accountant.actor_name}.sqlite') {
		os.rm('${accountant.db_dir}/${accountant.actor_name}.sqlite')!
	}
}

// creates the Budget with the given object id
pub fn test_create_budget() ! {
	mut actor := get(name: accountant.actor_name)!
	mut budget_id := actor.create_budget(Budget{})!
	assert budget_id == 1

	budget_id = actor.create_budget(Budget{})!
	assert budget_id == 2
}

// creates the Budget with the given object id
pub fn test_read_budget() ! {
	mut actor := get(name: accountant.actor_name)!
	mut budget := Budget{}
	budget.id = '${actor.create_budget(budget)!}'
	assert budget == actor.read_budget(budget.id)!
}
