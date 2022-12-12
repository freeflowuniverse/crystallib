module actionrunner

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.console
import freeflowuniverse.crystallib.texttools
import time
import os

//the main process which coordinate alls
[heap]
pub struct Scheduler {
pub mut:
	sessions map[string]SchedulerSession
	logger console.Logger
}

pub fn scheduler_new() Scheduler {
	return Scheduler{}
}

fn (mut scheduler Scheduler) session_new(name string) !SchedulerSession{
	scheduler.sessions[name] = SchedulerSession{name:name}
	mut session := scheduler.sessions[name]
	mut gitrunner := new_gitrunner()
	session.gitrunner = gitrunner
	go gitrunner.run()

	// mut booksrunner := new_booksrunner()
	// session.channels["books"] = gitrunner
	// go booksrunner.run()

	time.sleep(200 * time.millisecond) //wait 0.2 sec to make sure its operational
	return session
}

fn (mut scheduler Scheduler) session_get(name string) !SchedulerSession{
	//TODO: more checks
	if !scheduler.sessions.keys().contains('name') {
		return error("Session with name '$name' not found.")
	}
	return scheduler.sessions[name]
}

