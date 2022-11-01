module actionrunner 

import freeflowuniverse.crystallib.actionparser { Action }

struct ActionMessage {
mut:
	name string
	params Params
	complete bool = false
}

pub interface Runner {
	channel chan ActionMessage
	run()?
}

fn (runner Runner) action_complete(msg ActionMessage) {
	mut response := msg
	response.complete = true
	runner.channel <- response
}