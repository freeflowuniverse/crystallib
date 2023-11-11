module actionsparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.baobab.smartid

pub struct Action {
pub mut:
	id         smartid.CID
	name       string              [required]
	cid        smartid.CID
	actor      string              [required] // is not always an actor in strict sense, is just the 2nd element
	priority   u8 = 10 // 0 is highest, do 10 as default
	params     paramsparser.Params
	result     paramsparser.Params // can be used to remember outputs
	sourcelink SourceLink          // pointer to index of item in doc
}

pub struct SourceLink {
	path        string // path of file where action is declared in
	block_index int    // index of action block within source_file
	md_index    int
}

pub fn (action Action) str() string {
	mut out := '!!'
	if action.actor != '' {
		out += '${action.actor}.'
	}
	out += '${action.name} '
	if !action.params.empty() {
		out += '\nParams:\n'
		out += texttools.indent(action.params.str(), '    ')
	}
	if !action.result.empty() {
		out += '\nResult:\n'
		out += texttools.indent(action.result.str(), '    ')
	}
	return out
}

// serialize to 3script
pub fn (action Action) script3() string {
	mut out := '!!'
	if action.actor != '' {
		out += '${action.actor}.'
	}
	out += '${action.name} '
	out += action.params.str()
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
