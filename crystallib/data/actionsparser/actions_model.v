module actionsparser

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.baobab.smartid

pub struct Actions {
pub mut:
	items        []Action // should be empty after filter action
	default_cid  smartid.CID
	defaultactor string
	errors       []ActionError
	result       paramsparser.Params // can be used to remember outputs
}

pub fn (actions Actions) str() string {
	mut out := '## Actions\n\n'
	for action in actions.items {
		out += '${action}'
	}
	if actions.errors.len > 0 {
		out += '### Errors\n\n'
	}
	for error in actions.errors {
		out += '${error}\n'
	}
	if !actions.result.empty() {
		out += '### Result\n\n${actions.result}'
	}
	return out
}
