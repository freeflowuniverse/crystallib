module markdownparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.data.actionparser
// import freeflowuniverse.crystallib.core.texttools

pub struct Action {
pub mut:
	content string
	action actionparser.Action
	processed bool
}

fn (mut action Action) process(mut items []DocItem) !int {
	if action.processed{
		items << action
		return 0
	}
	action.action=actionparser.parse(action.content)!
	action.processed = true
	items << action
	return 1
	
}

fn (action Action) wiki() string {
	return action.action.script3() or {panic(err)}
}

fn (action Action) html() string {
	return action.wiki()
}

// is set of actions in a codeblock
pub struct Actions {
pub mut:
	content string
	actions []Action
}

fn (mut actions Actions) process(mut items []DocItem) !int {
	for mut action in actions.actions {
		action.process()!
	}
}

fn (actions Actions) wiki() string {
	return actions.content
}

fn (actions Actions) html() string {
	return actions.wiki()
}

// fn (actions Actions) str() string {
// 	mut out := '**** ACTIONS\n'
// 	for action in actions.items {
// 		out += '  ** ACTION ${action.name}\n'
// 	}
// 	return out
// }

// fn (mut actions Actions) action_add(a Action){
// 	println(a)
// }
