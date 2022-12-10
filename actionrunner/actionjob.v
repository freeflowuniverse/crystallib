module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.params { Params }
import time
import os

// the path of the directory in which the action job files will be located
const dirpath = './'

enum ActionJobState{
	init
	tostart
	recurring
	active
	ok
	error
}

// change action runner to be able to have 3 states + result as return: 
// ok, error, restart 
enum ActionJobReturnState{
	ok
	error
	restart
}

[heap]
pub struct ActionJob {
pub mut:
	id u32					//unique id
	guid string
	actionname     string 	//actionname
	params   Params
	state ActionJobState
	start time.Time
	end time.Time
	error string
	db map[string]string 		//used to keep state between
	dependencies []ActionJob 	//list the dependencies
	timeout u16					//time in seconds, 0 means we wait for ever
}

// change action runner to be able to have 3 states + result as return: 
[heap]
pub struct ActionJobReturn {
pub mut:
	job ActionJob
	state ActionJobReturnState
	result string // action runner gets result field as params json (is dict of strings)
}

//return true if all dependencies are done
pub fn (mut job ActionJob) check_dependencies_done() bool {
	for jopdep in job.dependencies{
		if jopdep.state != .ok && jopdep.state != .error{
			return false //means is still active
		}
	}
	return true
}

//return all dependencies which are in error state
pub fn (mut job ActionJob) dependencies_errors() []ActionJob{
	mut res := []ActionJob{}
	for jopdep in job.dependencies{
		if jopdep.state == .error{
			res << jopdep
		}
	}	
	return res
}

//return true if we didn't reach timeout yet
pub fn (mut job ActionJob) check_timeout_ok() bool {
	if job.timeout==0{
		return true
	}
	deadline := job.start.unix_time()+i64(job.timeout)
	if deadline < time.now().unix_time(){
		return false
	}
	return true
}

struct ToStartArgs{
	grace_period int = 0// grace period is in seconds, if not specified is immediate
}

// if grace specified job will only start X seconds later as last moddate of the job file
pub fn (mut job ActionJob) state_tostart(args ToStartArgs)! {

	// todo: should also except other cases
	if job.state != .init {
		return error("state should be init of $job")
	}
	job.state = .tostart
}

// if grace specified job will only start X seconds later as last moddate of the job file
pub fn (mut job ActionJob) state_recurring(args ToStartArgs)! {
	if job.state != .tostart{
		return error("state should be init of $job")
	}
	job.state = .recurring
}

pub fn (mut job ActionJob) state_active()! {
	if job.state != .tostart{
		return error("state should be tostart of $job")
	}
	job.state = .active
}

pub fn (mut job ActionJob) state_ok()! {
	if job.state != .active{
		return error("state should be active of $job")
	}
	job.state = .ok
}

pub fn (mut job ActionJob) state_error()! {
	if job.state != .active{
		return error("state should be active of $job")
	}
	job.state = .error
}

pub fn (mut job ActionJob) error(msg string) {
	job.state = .error
	job.error = "$msg"
}

// update state changes job state 
// upon receiving state update message from channel
pub fn (mut job ActionJob) update_state(state string)! {
	match state {
		'active' {
			job.state_active()! 	
		}
		'done' {
			job.state_ok()! 	
		}
		else {}
	}
}

// handles the returned actionjob depending on return state, 
// writes response to state dir, updates state accordingly
pub fn (mut job ActionJob) handle_return(job_return ActionJobReturn) ! {

	// on every state change of params/job items store as 
	// state/$jobguid_letter1_letter2/$jobguid_letter3_letter4/$jobguid.json 
	filepath := '$dirpath/state/$job_return.state/${job.guid[..2]}/${job.guid[2..4]}/${job.guid}.json'

	// action runner gets result field as params json (is dict of strings) that gets stored in state folder
	os.write_file(filepath, job_return.result) or { panic('cannot write result to state: $err') }

	match job_return.state {
		.error { job.state_error()! }
		.ok { job.state_ok()! }
		// there can be errors e.g. not reaching a service, which can be retried, 
		// moves the action back to 'tostart' with a 2s grace period
		.restart { job.state_tostart(grace_period: 2)! } // 2s grace period
	}
}

pub fn (job ActionJob) get_state() {
	
}