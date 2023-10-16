module actionsparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools

pub struct Action {
pub mut:
	name     string        [required]
	domain   string = 'protocol_me'
	actor    string        [required]
	circle   string        [required]
	priority u8 = 10 // 0 is highest, do 10 as default
	params   params.Params
	context  Context // pointer to index of item in doc
}

pub struct Context {
	source_file string // path of file where action is declared in
	block_index int    // index of action block within source_file
}

pub struct DocPointer {
	doc_path   string
	item_index int
}

pub struct Actions {
pub mut:
	actions       []Action // should be empty after filter action
	defaultdomain string = 'protocol_me'
	defaultcircle string
	defaultactor  string
	errors        []ActionError
	results       map[string]string
}

pub fn (actions Actions) str() string {
	mut out := '## Actions\n\n'
	for action in actions.actions {
		out += '${action}'
	}
	if actions.errors.len > 0 {
		out += '### errors\n\n'
	}
	for error in actions.errors {
		out += '${error}\n'
	}

	if actions.results.len > 0 {
		out += '### results\n\n'
	}
	for key, val in actions.results {
		out += '	${key}:${val}\n'
	}

	return out
}

pub fn (action Action) str() string {
	mut out := '!!'
	if action.domain != 'protocol_me' {
		out += '${action.domain}.'
	}
	if action.actor != '' {
		out += '${action.actor}.'
	}
	out += '${action.name} '
	out += '\n${action.params}\n'
	return out
}

// return list of names .
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
