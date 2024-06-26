module juggler

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import time

pub struct Trigger {
	GitTrigger
pub:
	name string
	description string
	event_id string
	script_ids []string // the ids of scripts that the trigger triggers
}

pub struct GitTrigger {
	repository Repository
	action GitAction
}

pub fn (t GitTrigger) is_triggered(e Event) bool {
	// if e is GitEvent {
		if e.repository.owner != t.repository.owner || e.repository.name != t.repository.name {
			return false
		}

		if e.action != t.action {
			return false
		}

		if t.repository.branch != 'default' && e.repository.branch == t.repository.branch {
			return true
		}
		if t.repository.branch == 'default' {
			return true
		}
	// } 
	return false
}

