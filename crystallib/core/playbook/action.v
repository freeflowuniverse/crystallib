module playbook

import crypto.blake2b
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.baobab.smartid

pub struct Action {
pub mut:
	id         int
	cid        string
	name       string
	actor      string
	priority   int = 10 // 0 is highest, do 10 as default
	params     paramsparser.Params
	result     paramsparser.Params // can be used to remember outputs
	execute    bool = true // certain actions can be defined but meant to be executed directly
	actiontype ActionType
	comments   string
	done       bool // if done then no longer need to process
}

pub enum ActionType {
	unknown
	dal
	sal
	wal
	macro
}

pub fn (action Action) str() string {
	mut out := action.script3()
	if !action.result.empty() {
		out += '\n\nResult:\n'
		out += texttools.indent(action.result.script3(), '    ')
	}
	return out
}

// serialize to 3script
pub fn (action Action) script3() string {
	mut out := ''
	if action.comments.len > 0 {
		out += texttools.indent(action.comments, '// ')
	}
	out += '!!'
	if action.actor != '' {
		out += '${action.actor}.'
	}
	out += '${action.name} '
	if action.id > 0 {
		out += 'id:${action.id} '
	}
	if !action.params.empty() {
		script3 := action.params.script3()
		script3_lines := script3.split_into_lines()
		out += script3_lines[0] + '\n'
		for line in script3_lines[1..] {
			out += '    ' + line + '\n'
		}
	}
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

// get hash from the action, should always be the same for the same action
pub fn (action Action) hashkey() string {
	txt := action.script3()
	bs := blake2b.sum160(txt.bytes())
	return bs.hex()
}
