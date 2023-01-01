module actionrunner

// import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.console
// import freeflowuniverse.crystallib.texttools
import time
import os
import rand

// the main process which coordinate alls
[heap]
pub struct Scheduler {
pub mut:
	logger   console.Logger
	path pathlib.Path
}

pub fn scheduler_new(path string) !Scheduler {
	mut p:=pathlib.get_dir(path,true)!
	mut scheduler:= Scheduler{path:p}
	scheduler.init()!
	// scheduler.start()!
	return scheduler
}

// creates folders necessary for actionrunner
fn (mut s Scheduler) init()! {
	folders := ['init', 'tostart', 'recurring', 'scheduled', 'active', 'done', 'state', 'logs',
		'error']
	for folder in folders {
		os.mkdir_all('${s.path.path}/${folder}')!
	}
}

//give a action file
//timeout in seconds
fn (mut s Scheduler) job_start(content string, dependencies []string, timeout u16)! {

	mut job:= ActionJob {
		domain:
		actor:
		action: name
		params: params
		start: time.now()
		guid: rand.uuid_v4()
		state: ActionJobState{}
		// grace_period:time.Duration
		dependencies:dependencies
		timeout:timeout
	}

}