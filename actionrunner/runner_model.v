module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.params { Params }

struct ActionMessage {
mut:
	name     string
	params   Params
	complete bool
}

pub interface Runner {
	channel chan ActionMessage
mut:
	run()
}

fn (runner Runner) action_complete(action Action) {
	mut response := ActionMessage{
		name: action.name
		params: action.params
		complete: true
	}
	runner.channel <- response
}
