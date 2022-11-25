module actionrunner

import freeflowuniverse.crystallib.actionparser { Action }
import freeflowuniverse.crystallib.params { Params }
import time


enum ActionJobState{
	init
	scheduled
	running
	ok
	error
}

[heap]
pub struct ActionJob {
pub mut:
	id u32					//unique id
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

//return true in all dependencies are done
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



pub fn (mut job ActionJob) state_scheduled()! {
	if job.state != .init{
		return error("state should be init of $job")
	}
	job.state = .scheduled
}

pub fn (mut job ActionJob) state_running()! {
	if job.state != .scheduled{
		return error("state should be scheduled of $job")
	}
	job.state = .running
}

pub fn (mut job ActionJob) state_ok()! {
	if job.state != .running{
		return error("state should be running of $job")
	}
	job.state = .ok
}

pub fn (mut job ActionJob) error( msg string) {
	job.state = .error
	job.error = "$msg"
}

// update state changes job state 
// upon receiving state update message from channel
pub fn (mut job ActionJob) update_state(state string)! {
	match state {
		'running' {
			job.state_running()! 	
		}
		'done' {
			job.state_ok()! 	
		}
		else {}
	}
}
