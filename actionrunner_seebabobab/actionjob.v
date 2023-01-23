module actionrunnerold

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.params { Params }
import time
import os
import json
import rand

// the path of the directory in which the action job files will be located
const dirpath = os.dir(@FILE) + '/example/filesystem'

enum ActionJobState {
	init
	tostart
	recurring
	scheduled
	active
	done
	error
}

enum ActionJobEvent {
	schedule // job has been pushed to the runner channel
	running // job has begun being run by runner
	ok // job has been successfully complete
	error // job has produced an error
	restart // job has produced an error and must restart
}

//actionjob as how its being send & received from bus
pub struct ActionJobPublic {
pub mut:
	src_jobid        u32 	//unique jobid (unique per actor which is unique per twin)
	src_twinid		 u32    //which twin is responsible for executing on behalf of actor
	src_actorid      u16	//unique actor id, runs on top of twin
	src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
	domain		 string
	actor		 string	
	action   	 string 	//actionname
	params       string
	state        string
	start        u64		//epoch
	end          u64		//epoch
	grace_period u32 		//wait till next run, in seconds
	error        string		//string description of what went wrong
	timeout      u32 		//time in seconds, 2h is maximum
}

pub struct ActionJobV {
pub mut:
	src_jobid        u32 	//unique jobid (unique per actor which is unique per twin)
	src_twinid		 u32    //which twin is responsible for executing on behalf of actor
	src_actorid      u16	//unique actor id, runs on top of twin
	src_rmbids		 []u32    //how do we find our way back, if 0 is local
	domain		 string
	actor		 string	
	action   	 string // actionname
	params       Params
	state        ActionJobState
	start        time.Time
	end          time.Time
	grace_period time.Duration  //wait till next run
	error        string
	timeout      time.Duration // time in seconds, 2h is maximum
}

fn (mut job ActionJobV) serialize() !string{
	params_data:=json.encode(job.params)

	mut job:=ActionJobPublic{
		src_jobid:src_jobid
		src_twinid:src_twinid
		src_actorid:src_actorid
		src_rmbid:src_rmbid
		domain:domain
		actor:actor
		action:action
		params:params_data


	}

}

// an actionjob can have 5 events + error msg as return:
// schedule, running, ok, error, restart
[heap]
pub struct ActionJobReturn {
pub mut:
	job_guid string
	event    ActionJobEvent
	error    string
}

// return true if all dependencies are done
pub fn (mut job ActionJob) check_dependencies_done() bool {
	//TODO: need to work with the ID's
	// for jopdep in job.dependencies {
	// 	if jopdep.state == .active {
	// 		return false // means is still active
	// 	}
	// }
	return true
}

// return all dependencies which are in error state
pub fn (mut job ActionJob) dependencies_errors() []ActionJob {
	mut res := []ActionJob{}
	// for jopdep in job.dependencies {
	// 	if jopdep.state == .error {
	// 		res << jopdep
	// 	}
	// }
	return res
}

// return true if we didn't reach timeout yet
pub fn (mut job ActionJob) check_timeout_ok() bool {
	if job.timeout == 0 {
		return true
	}
	deadline := job.start.unix_time() + i64(job.timeout)
	if deadline < time.now().unix_time() {
		return false
	}
	return true
}

// creates new actionjob
pub fn new_actionjob(name string, params Params) ActionJob {
	return ActionJob{
		actionname: name
		params: params
		start: time.now()
		guid: rand.uuid_v4()
	}
}

struct StateArgs {
	state        ActionJobState
	grace_period time.Duration = 0 * time.second
}

// used for creating state files on session load or recovery
// NOT used for state updates, only individual event handlers update state
fn (mut job ActionJob) load_state(args StateArgs) ! {
	job.state = args.state
	os.write_file('${actionrunner.dirpath}/${args.state}/${job.guid}', '') or {
		panic('Cannot create actionfile for job: ${err}')
	}
	job.log('Action job loaded with state ${args.state}')
}

// schedule event handler, updates state and filesystem to scheduled
pub fn (mut job ActionJob) event_schedule() ! {
	if job.state != .tostart && job.state != .recurring {
		return error('Schedule event can only be emmitted by a job that is recurring or tostart')
	}

	// copies job instead of moving if recurring
	if job.state == .recurring {
		os.cp('${actionrunner.dirpath}/recurring/${job.guid}', '${actionrunner.dirpath}/scheduled/${job.guid}') or {
			panic('Failed to copy actionfile from recurring to tostart: ${err}')
		}
	} else {
		os.mv('${actionrunner.dirpath}/tostart/${job.guid}', '${actionrunner.dirpath}/scheduled/${job.guid}') or {
			panic('Failed to move actionfile from scheduled to active: ${err}')
		}
	}

	job.state = .scheduled
	job.log('Action job is scheduled')
}

// running event handler, updates state and filesystem from scheduled to active
pub fn (mut job ActionJob) event_running() ! {
	if job.state != .scheduled {
		return error('Running event can only be emmitted by a scheduled job')
	}
	os.mv('${actionrunner.dirpath}/scheduled/${job.guid}', '${actionrunner.dirpath}/active/${job.guid}') or {
		panic('Failed to move actionfile from scheduled to active: ${err}')
	}
	job.state = .active
	job.log('Action job is active')
}

// ok event handler, updates state and filesystem from active to done
pub fn (mut job ActionJob) event_ok() ! {
	if job.state != .active {
		return error('Ok event can only be emmitted by an active job')
	}
	os.mv('${actionrunner.dirpath}/active/${job.guid}', '${actionrunner.dirpath}/done/${job.guid}') or {
		panic('Failed to move actionfile from active to done: ${err}')
	}
	job.state = .done
	job.log('Action job is done')
}

// ok event handler, updates state and filesystem from active to error
pub fn (mut job ActionJob) event_error() ! {
	if job.state != .active {
		return error('Error event can only be emmitted by an active job')
	}
	os.mv('${actionrunner.dirpath}/active/${job.guid}', '${actionrunner.dirpath}/error/${job.guid}') or {
		panic('Failed to move actionfile from active to error: ${job.error}')
	}
	job.state = .error
	job.log('Action job has returned an error: ${job.error}')
}

// there can be errors e.g. not reaching a service, which can be retried,
// moves the action back to 'tostart' with a 2s grace period
pub fn (mut job ActionJob) event_restart() ! {
	if job.state != .active {
		return error('Restart event can only be emmitted by an active job')
	}
	os.mv('${actionrunner.dirpath}/active/${job.guid}', '${actionrunner.dirpath}/tostart/${job.guid}') or {
		panic('Failed to move actionfile from active to tostart: ${err}')
	}
	job.state = .tostart
	job.grace_period = 2 * time.second
	job.log('Action job has returned an error and will restart')
}

pub fn (mut job ActionJob) log(msg string) {
	filepath := '${actionrunner.dirpath}/logs/${job.guid}.log'
	if os.exists(filepath) {
		os.execute('echo [${time.now().format_ss_micro()}] - ${msg} >> ${filepath}')
	} else {
		os.write_file(filepath, '[${time.now().format_ss_micro()}] - ${msg}\n') or {
			panic('cannot write log to file: ${err}')
		}
	}
}

// shorthand for throwing job errors with messages
pub fn (mut job ActionJob) error(msg string) {
	job.error = msg
	job.handle_event(.error) or { panic('Error') }
}

// writes response to state fs database, updates state accordingly
pub fn (mut job ActionJob) handle_event(event ActionJobEvent) ! {
	match event {
		.schedule { job.event_schedule()! }
		.running { job.event_running()! }
		.error { job.event_error()! }
		.ok { job.event_ok()! }
		.restart { job.event_restart()! }
	}

	// on every state change of params/job items store as
	// state/$jobguid_letter1_letter2/$jobguid_letter3_letter4/$jobguid.json
	os.mkdir_all('${actionrunner.dirpath}/state/${job.guid[..2]}/${job.guid[2..4]}')!
	filepath := '${actionrunner.dirpath}/state/${job.guid[..2]}/${job.guid[2..4]}/${job.guid}.json'

	// todo: convert intoo params first
	// action runner gets returned job as params
	// encodes into json that gets stored in state folder
	os.write_file(filepath, json.encode(job)) or { panic('cannot write result to state: ${err}') }
}
