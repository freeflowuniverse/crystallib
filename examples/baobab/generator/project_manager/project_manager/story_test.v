module testactor

import os
import source { Story }

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'TestActor_test_actor'

//
pub fn testsuite_begin() {
	if os.exists('${testactor.db_dir}/${testactor.actor_name}') {
		os.rmdir_all('${testactor.db_dir}/${testactor.actor_name}')!
	}
	if os.exists('${testactor.db_dir}/${testactor.actor_name}.sqlite') {
		os.rm('${testactor.db_dir}/${testactor.actor_name}.sqlite')!
	}
}

//
pub fn testsuite_end() {
	if os.exists('${testactor.db_dir}/${testactor.actor_name}') {
		os.rmdir_all('${testactor.db_dir}/${testactor.actor_name}')!
	}
	if os.exists('${testactor.db_dir}/${testactor.actor_name}.sqlite') {
		os.rm('${testactor.db_dir}/${testactor.actor_name}.sqlite')!
	}
}

// creates the Story with the given object id
pub fn test_create_story() ! {
	mut actor := get(name: testactor.actor_name)!
	mut story_id := actor.create_story(Story{ name: '' })!
	assert story_id == 1

	story_id = actor.create_story(Story{ name: '' })!
	assert story_id == 2
}

// creates the Story with the given object id
pub fn test_filter_story() ! {
	mut actor := get(name: testactor.actor_name)!

	story_id0 := actor.create_story(Story{ tag: 'test_string', name: 'test_string' })!
	story_list0 := actor.filter_story(
		filter: StoryFilter{
			tag: 'test_string'
		}
	)!
	assert story_list0.len == 1
	assert story_list0[0].tag == 'test_string'
}
