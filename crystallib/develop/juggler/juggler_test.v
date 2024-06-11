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
	mut j := get(name: '${instance_name}0')!
	spawn j.run(8085)
}

pub fn test_juggler_index() {
	mut j := get(name: '${instance_name}1')!
	j.index(mut juggler.Context{})
}

pub fn test_juggler_trigger() {
	mut j := get(name: '${instance_name}2')!
	j.trigger(mut juggler.Context{})
}

pub fn test_juggler_get_repo_playbook() ! {
	mut j := get(
		name: '${instance_name}3'
		url: 
	)!

	// should return none since event is empty
	if _ := j.get_repo_playbook(Event {}) {
		assert false
	} else {
		assert true
	}

	// should return none since event is empty
	if _ := j.get_repo_playbook(Event {}) {
		assert false
	} else {
		assert true
	}

}

// pub fn test_open() ! {
// 	mut j := get(name: instance_name)!
// 	j.open()!
// }
