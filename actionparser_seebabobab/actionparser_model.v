module actionparser

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

pub struct ActionsParser {
pub mut:
	actions []Action
}

pub struct Action {
pub:
	name string
pub mut:
	params params.Params
}

// get the param as string, if it does not exist will throw error
pub fn (mut action Action) param_get(name_ string) !string {
	return action.params.get(name_)
}

pub fn (action Action) str() string {
	p := 'ACTION: ${action.name}\n${action.params}'
	return p
}

//return list of names
//the names are normalized (no special chars, lowercase, ... )
pub fn (action Action) names() []string {
	mut names := []string{}
	for name in action.name.split("."){
		names << texttools.name_fix(name)
	}
	return names
}


enum ActionState {
	init //first state
	next //will continue with next steps
	restart
	error
	done //means we don't process the next ones
}
