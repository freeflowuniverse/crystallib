module juggler

import freeflowuniverse.crystallib.core.pathlib
import time

pub struct Trigger {
pub:
	event Event
	script Script
}

pub struct Event {
pub:
	repository Repository
	commit Commit
	time time.Time
}

pub fn (e Event) name() string {
	return 'git push ${e.repository.full_name()}'
}

pub struct Script {
pub:
	identifier string
	name string
	url string
	path pathlib.Path
	status string
}

// a play of a script due to a trigger that occurs
pub struct Play {
	Trigger
pub:
	status Status // status of the play
	output string // output of the play
	start time.Time // time the play started
	end time.Time // time the play ended
}

pub fn (p Play) duration() time.Duration {
	return p.end-p.start
}

pub enum Status {
	starting
	running
	success
	error
}