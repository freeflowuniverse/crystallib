module actions

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

pub struct Action {
pub mut:
	name     string        [required]
	domain   string = 'protocol_me'
	actor    string        [required]
	book     string        [required]
	priority u8 // 0 is highest
	params   params.Params
}

pub fn (action Action) str() string {
	p := 'ACTION: ${action.name}\n${action.params}'
	return p
}

// return list of names
// the names are normalized (no special chars, lowercase, ... )
pub fn (action Action) names() []string {
	mut names := []string{}
	for name in action.name.split('.') {
		names << texttools.name_fix(name)
	}
	return names
}

pub enum ActionState {
	init // first state
	next // will continue with next steps
	restart
	error
	done // means we don't process the next ones
}
