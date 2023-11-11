module actionsparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.baobab.smartid

pub struct Parser {
pub mut:
	actions      []Action // should be empty after filter action
	default_cid  smartid.CID
	defaultactor string
	errors       []ActionError
}

pub fn (parser Parser) str() string {
	mut out := '## Parser\n\n'
	for action in parser.actions {
		out += '${action}'
	}
	if parser.errors.len > 0 {
		out += '### Errors\n\n'
	}
	for error in parser.errors {
		out += '${error}\n'
	}
	// if !parser.result.empty() {
	// 	out += '### Result\n\n${parser.result}'
	// }
	return out
}
