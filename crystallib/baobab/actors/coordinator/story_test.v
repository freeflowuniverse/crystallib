module coordinator

import os
import baobab.seeds.project { Story }

const db_dir = '${os.home_dir()}/hero/db'
const actor_name = 'Coordinator_test_actor'

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

// news the Story with the given object id
pub fn test_new_story() ! {
	mut actor := get(name: coordinator.actor_name)!
	mut story_id := actor.new_story(Story{ name: 'mock_string_FNl' })!
	assert story_id == '1'

	story_id = actor.new_story(Story{ name: 'mock_string_FNl' })!
	assert story_id == '2'
}

// news the Story with the given object id
pub fn test_get_story() ! {
	mut actor := get(name: coordinator.actor_name)!
	mut story := Story{
		name: 'mock_string_Lgg'
	}
	story.id = '${actor.new_story(story)!}'
	assert story == actor.get_story(story.id)!
}

// news the Story with the given object id
pub fn test_filter_story() ! {
	mut actor := get(name: coordinator.actor_name)!

	story_id0 := actor.new_story(Story{ tag: 'mock_string_PZr', name: 'mock_string_cCE' })!
	story_list0 := actor.filter_story(
		filter: StoryFilter{
			tag: 'mock_string_PZr'
		}
	)!
	assert story_list0.len == 1
	assert story_list0[0].tag == 'mock_string_PZr'
}
