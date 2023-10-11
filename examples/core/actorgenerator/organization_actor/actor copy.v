module example

import freeflowuniverse.crystallib.baobab.actions as actionslib {ActionsArgs, Actions}
import freeflowuniverse.crystallib.data.params as paramslib {Params}

_global(
	actor_factory := map[string]shared ExampleActor
)

struct ExampleActor {
	epic_map   map[string]&Epic   //
	sprint_map map[string]&Sprint //
	story_map  map[string]&Story  //
}

// PlayConfig. If actions are provided runs actions. Otherwise loads and runs actions in path.
pub struct Play {
	ActionsArgs
	actions []Actions
}

pub fn play(params Play) {
	actor_actions := if params.actions.len > 0 {
		params.actions.filtersort(actor: '')
	} else {
		actionslib.new(params.ActionsArgs)
	}

	actions := actor_actions

	for action in actions {
		shared actor := actor_factory[cid]
		lock actor {
			actor.act(action)
		}
	}
}

fn (actor ExampleActor) act(action actions.Action) {
	'get_epic'
	{
		actor.get_epic(action.params)!
	}
	'set_epic'
	{
		actor.set_epic(action.params)!
	}
	'delete_epic'
	{
		actor.delete_epic(action.params)!
	}
	'create_epic'
	{
		actor.create_epic(action.params)!
	}
	'get_sprint'
	{
		actor.get_sprint(action.params)!
	}
	'set_sprint'
	{
		actor.set_sprint(action.params)!
	}
	'delete_sprint'
	{
		actor.delete_sprint(action.params)!
	}
	'create_sprint'
	{
		actor.create_sprint(action.params)!
	}
	'get_story'
	{
		actor.get_story(action.params)!
	}
	'set_story'
	{
		actor.set_story(action.params)!
	}
	'delete_story'
	{
		actor.delete_story(action.params)!
	}
	'create_story'
	{
		actor.create_story(action.params)!
	}
}

pub fn (actor ExampleActor) get_epic(params Params) !Epic {
	id := params.get('id')!
	object := actor.epic_map[id]
	return object
}

pub fn (actor ExampleActor) set_epic(params Params) !Epic {
	id := params.get('id')!
	object := actor.epic_map[id]
	return object
}

pub fn (actor ExampleActor) delete_epic(params Params) ! {
	id := params.get('id')!
	actor.epic_map.delete(id)
	return object
}

pub fn (actor ExampleActor) create_epic(params Params) ! {
	id := params.get('id')!
	if id in actor.epic_map {
		return error('Root object with id already exists.')
	}
	actor.epic_map[id] = Epic{}
}

pub fn (actor ExampleActor) get_sprint(params Params) !Sprint {
	id := params.get('id')!
	object := actor.sprint_map[id]
	return object
}

pub fn (actor ExampleActor) set_sprint(params Params) !Sprint {
	id := params.get('id')!
	object := actor.sprint_map[id]
	return object
}

pub fn (actor ExampleActor) delete_sprint(params Params) ! {
	id := params.get('id')!
	actor.sprint_map.delete(id)
	return object
}

pub fn (actor ExampleActor) create_sprint(params Params) ! {
	id := params.get('id')!
	if id in actor.sprint_map {
		return error('Root object with id already exists.')
	}
	actor.sprint_map[id] = Sprint{}
}

pub fn (actor ExampleActor) get_story(params Params) !Story {
	id := params.get('id')!
	object := actor.story_map[id]
	return object
}

pub fn (actor ExampleActor) set_story(params Params) !Story {
	id := params.get('id')!
	object := actor.story_map[id]
	return object
}

pub fn (actor ExampleActor) delete_story(params Params) ! {
	id := params.get('id')!
	actor.story_map.delete(id)
	return object
}

pub fn (actor ExampleActor) create_story(params Params) ! {
	id := params.get('id')!
	if id in actor.story_map {
		return error('Root object with id already exists.')
	}
	actor.story_map[id] = Story{
		title: params.get('title')!
		description: params.get('description')!
		tasks: Task{
			story_id: params.get('tasks_story_id')!
			asignee: params.get('tasks_asignee')!
			title: params.get('tasks_title')!
			description: params.get('tasks_description')!
			priority: {
			}
		}
	}
}
