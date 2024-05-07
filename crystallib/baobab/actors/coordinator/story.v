module coordinator

import baobab.seeds.project { Story }
import freeflowuniverse.crystallib.baobab.backend { FilterParams }

// creates the Story with the given object id
pub fn (mut actor Coordinator) create_story(story Story) !int {
	return actor.backend.new[Story](story)!
}

// gets the story with the given object id
pub fn (mut actor Coordinator) read_story(id string) !Story {
	return actor.backend.get[Story](id)!
}

// gets the Story with the given object id
pub fn (mut actor Coordinator) update_story(story Story) ! {
	actor.backend.set[Story](story)!
}

// deletes the Story with the given object id
pub fn (mut actor Coordinator) delete_story(id int) ! {
	actor.backend.delete[Story](id)!
}

// lists all of the story objects
pub fn (mut actor Coordinator) list_story() ![]Story {
	return actor.backend.list[Story]()!
}

struct FilterStoryParams {
	filter StoryFilter
	params FilterParams
}

struct StoryFilter {
pub mut:
	tag string
}

// lists all of the story objects
pub fn (mut actor Coordinator) filter_story(filter FilterStoryParams) ![]Story {
	return actor.backend.filter[Story, StoryFilter](filter.filter, filter.params)!
}
