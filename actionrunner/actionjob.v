module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.params { Params }
import time
import os
import json
import rand

// the path of the directory in which the action job files will be located
const dirpath = os.dir(@FILE) + '/filesystem'

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

// returns actionjob object from filesystem
// // todo: maybe also keep a map so can be retreived from state?
// pub fn get(guid string) ActionJob {
// 	for folder in ['init', 'tostart', ''] {
		
// 	}
// 	if os.exists()
// }

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

pub fn (mut job ActionJob) state_init()! {
	// todo: perform checks
	job.state = .init
	job.guid = rand.uuid_v4()
	os.write_file('$dirpath/init/$job.guid', json.encode(job)) or {panic('cannt write actionfile: $err')}
	job.log('Action job initialized.')
}

// if grace specified job will only start X seconds later as last moddate of the job file
pub fn (mut job ActionJob) state_tostart(args ToStartArgs)! {

	// todo: should also except other cases
	if job.state != .init {
		return error("state should be init of $job")
	}

	os.mv('$dirpath/init/$job.guid', '$dirpath/tostart') or {
		panic('Cannot move actionfile from init to tostart: $err')
	}
	job.state = .tostart
	job.log('Action job tostart.')
}

// if grace specified job will only start X seconds later as last moddate of the job file
pub fn (mut job ActionJob) state_recurring(args ToStartArgs)! {
	if job.state != .init{
		return error("state should be init of $job")
	}
	job.state = .recurring
	job.log('Action job recurring.')
}

pub fn (mut job ActionJob) state_active()! {
	if job.state != .tostart{
		return error("state should be tostart of $job")
	}
	os.mv('$dirpath/tostart/$job.guid', '$dirpath/active') or {
		panic('Cannot move actionfile from tostart to active: $err')
	}
	job.state = .active
	job.log('Action job active.')
}

pub fn (mut job ActionJob) state_ok()! {
	if job.state != .active{
		return error("state should be active of $job")
	}
	os.mv('$dirpath/active/$job.guid', '$dirpath/done') or {
		panic('Cannot move actionfile from active to done: $err')
	}
	job.state = .ok
	job.log('Action job done.')
}

pub fn (mut job ActionJob) state_error()! {
	if job.state != .active{
		return error("state should be active of $job")
	}
	job.state = .error
	job.log('Action job error.')
}

pub fn (mut job ActionJob) error(msg string) {
	job.state = .error
	job.error = "$msg"
}

pub fn (mut job ActionJob) log(msg string) {
	filepath := '$dirpath/logs/${job.guid}.log'
	if os.exists(filepath) {
		os.execute('echo [${time.now().format_ss_micro()}] - $msg >> $filepath')
	} else {
		os.write_file(filepath, '[${time.now().format_ss_micro()}] - $msg\n') or { panic('cannot write log to file: $err') }
	}
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
pub fn (mut job ActionJob) handle_return(state ActionJobReturnState, result string) ! {

	// on every state change of params/job items store as 
	// state/$jobguid_letter1_letter2/$jobguid_letter3_letter4/$jobguid.json 
	os.mkdir_all('$dirpath/state/$state/${job.guid[..2]}/${job.guid[2..4]}')!
	filepath := '$dirpath/state/$state/${job.guid[..2]}/${job.guid[2..4]}/${job.guid}.json'

	// action runner gets result field as params json (is dict of strings) that gets stored in state folder
	os.write_file(filepath, result) or { panic('cannot write result to state: $err') }

	match state {
		.error { job.state_error()! }
		.ok { job.state_ok()! }
		// there can be errors e.g. not reaching a service, which can be retried, 
		// moves the action back to 'tostart' with a 2s grace period
		.restart { job.state_tostart(grace_period: 2)! } // 2s grace period
	}
}