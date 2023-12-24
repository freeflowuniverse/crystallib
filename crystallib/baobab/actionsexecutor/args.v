module actionsexecutor

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.baobab.context

@[params]
pub struct ActionExecArgs {
pub mut:
	session ?context.Session
	action  playbook.Action
}
