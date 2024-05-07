module coordinator

import os
import baobab.seeds.project { Story }

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'Coordinator_test_actor'

//
pub fn testsuite_begin() {
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}') {
		os.rmdir_all('${coordinator.db_dir}/${coordinator.actor_name}')!
	}
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}.sqlite') {
		os.rm('${coordinator.db_dir}/${coordinator.actor_name}.sqlite')!
	}
}

//
pub fn testsuite_end() {
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}') {
		os.rmdir_all('${coordinator.db_dir}/${coordinator.actor_name}')!
	}
	if os.exists('${coordinator.db_dir}/${coordinator.actor_name}.sqlite') {
		os.rm('${coordinator.db_dir}/${coordinator.actor_name}.sqlite')!
	}
}

// creates the Story with the given object id
pub fn test_create_story() ! {
	mut actor := get(name: coordinator.actor_name)!
	mut story_id := actor.create_story(Story{ name: 'mock_string_Bkg' })!
	assert story_id == 1

	story_id = actor.create_story(Story{ name: 'mock_string_Bkg' })!
	assert story_id == 2
}

// creates the Story with the given object id
pub fn test_read_story() ! {
	mut actor := get(name: coordinator.actor_name)!
	mut story := Story{
		name: 'mock_string_nmx'
	}
	story.id = '${actor.create_story(story)!}'
	assert story == actor.read_story(story.id)!
}

// creates the Story with the given object id
pub fn test_filter_story() ! {
	mut actor := get(name: coordinator.actor_name)!

	story_id0 := actor.create_story(Story{ tag: 'mock_string_ndP', name: 'mock_string_JGl' })!
	story_list0 := actor.filter_story(
		filter: StoryFilter{
			tag: 'mock_string_ndP'
		}
	)!
	assert story_list0.len == 1
	assert story_list0[0].tag == 'mock_string_ndP'
}
