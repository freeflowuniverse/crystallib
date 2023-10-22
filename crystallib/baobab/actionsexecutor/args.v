module actionsexecutor

import freeflowuniverse.crystallib.data.actionsparser
import freeflowuniverse.crystallib.baobab.context

[params]
pub struct ActionExecArgs {
pub mut:
	session ?context.Session
	action  actionsparser.Action
}
