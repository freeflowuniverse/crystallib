module scheduler

import os
import baobab.seeds.schedule { Calendar }

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'Scheduler_test_actor'

//
pub fn testsuite_begin() {
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}') {
		os.rmdir_all('${scheduler.db_dir}/${scheduler.actor_name}')!
	}
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}.sqlite') {
		os.rm('${scheduler.db_dir}/${scheduler.actor_name}.sqlite')!
	}
}

//
pub fn testsuite_end() {
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}') {
		os.rmdir_all('${scheduler.db_dir}/${scheduler.actor_name}')!
	}
	if os.exists('${scheduler.db_dir}/${scheduler.actor_name}.sqlite') {
		os.rm('${scheduler.db_dir}/${scheduler.actor_name}.sqlite')!
	}
}

// creates the Calendar with the given object id
pub fn test_create_calendar() ! {
	mut actor := get(name: scheduler.actor_name)!
	mut calendar_id := actor.create_calendar(Calendar{})!
	assert calendar_id == 1

	calendar_id = actor.create_calendar(Calendar{})!
	assert calendar_id == 2
}

// creates the Calendar with the given object id
pub fn test_read_calendar() ! {
	mut actor := get(name: scheduler.actor_name)!
	mut calendar := Calendar{}
	calendar.id = '${actor.create_calendar(calendar)!}'
	assert calendar == actor.read_calendar(calendar.id)!
}

// creates the Calendar with the given object id
pub fn test_filter_calendar() ! {
	mut actor := get(name: scheduler.actor_name)!

	calendar_id0 := actor.create_calendar(Calendar{ tag: 'mock_string_dTR' })!
	calendar_list0 := actor.filter_calendar(
		filter: CalendarFilter{
			tag: 'mock_string_dTR'
		}
	)!
	assert calendar_list0.len == 1
	assert calendar_list0[0].tag == 'mock_string_dTR'
}
