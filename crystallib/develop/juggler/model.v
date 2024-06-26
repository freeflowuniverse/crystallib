module juggler

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import time

pub enum GitAction {
	push
	commit
}

pub struct Event {
pub mut:
	id u32
	object_id u32
	commit Commit
	time time.Time
	action GitAction
}

pub struct GitEvent {
pub mut:
	id u32
	repository Repository
	commit Commit
	time time.Time
	action GitAction
}

pub fn (e Event) name() string {
	// if e is GitEvent {
	return 'git push to'
	// } else {
	// 	panic('implement')
	// }
}

pub fn (e Event) category() string {
	// if e is GitEvent {
	return e.category()
	// } else {
	// 	panic('implement')
	// }
}

pub fn (mut j Juggler) event_card(event_id u32) !string {
	event := j.backend.get[Event](event_id)!
	repo := j.backend.get[Repository](event.object_id)!
	return event.card(repo)
}
pub fn (event Event) card(repository Repository) string {
	return $tmpl('./templates/event_card.html')
}

pub fn (play Play) row() string {
	return $tmpl('./templates/play_row.html')
	
}

pub fn (e GitEvent) category() string {
	return 'git push'
}

pub struct CustomEvent {
pub:
	time time.Time
}

pub fn (e GitEvent) name() string {
	return 'git push ${e.repository.full_name()}'
}

pub struct Script {
pub mut:
	id u32
	name string
	description string
	url string
	path string
	status string
	category ScriptCategory
}

pub fn (s Script) id() string {
	println('iding script ${s}')
	return s.name.replace('.', '_')
}

pub fn (play Play) id() string {
	return '${play.event_id}_${texttools.name_fix(play.script_id)}'
}

// a play of a script due to a trigger that occurs
pub struct Play {
pub mut:
	id u32
	script_id string // id of script that is played
	event_id u32 // id of event that triggered the play
	// event Event
	trigger_id string
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