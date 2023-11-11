module actionsexecutor

import freeflowuniverse.crystallib.data.actionparser
import freeflowuniverse.crystallib.baobab.context

[params]
pub struct ActionExecArgs {
pub mut:
	session ?context.Session
	action  actionparser.Action
}
