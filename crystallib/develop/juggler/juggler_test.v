module juggler

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.clients.dagu { DAG }
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.servers.caddy
import veb
import json

const instance_name = 'testinstance'

pub fn test_juggler_run() ! {
	mut j := get(name: instance_name)!
	spawn j.run(8085)
}

pub fn test_juggler_index() {
	mut j := get(name: instance_name)!
	j.index(mut juggler.Context{})
}

pub fn test_juggler_trigger() {
	mut j := get(name: instance_name)!
	j.trigger(mut juggler.Context{})
}

pub fn test_juggler_get_repo_playbook() ! {
	mut j := get(name: instance_name)!
	j.get_repo_playbook(Event {})
}

pub fn test_open() ! {
	mut j := get(name: instance_name)!
	j.open()!
}
