module actionsparser

import freeflowuniverse.crystallib.core.texttools

pub struct ActionError {
pub mut:
	action Action
	msg    string [required]
}

pub fn (mut parser Parser) error_add(action Action, msg string) {
	e := ActionError{
		action: action
		msg: msg
	}
	parser.errors << e
}

pub fn (error ActionError) str() string {
	mut out := '#### Error\n\n'
	out += ' - action:${error.action.name}'
	if error.msg.contains('\n') {
		out += ' - error:\n${texttools.indent(error.msg, '    ')}'
	} else {
		out += " - error:'${error.msg}'"
	}
	return out
}
