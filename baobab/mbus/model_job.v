module mbus

import freeflowuniverse.crystallib.params { Params }
import time

// The possible states of a job
pub enum ActionJobState {
	init
	tostart
	recurring
	scheduled
	active
	done
	error
}

pub struct ActionJobs {
pub mut:
	jobs []ActionJob
}

// The internal representation of a job. For params see
// github/freeflowuniverse/crystallib/params/readme.md.
pub struct ActionJob {
pub mut:
	guid         string // unique jobid (unique per actor which is unique per twin)
	twinid       u32    // which twin needs to execute the action
	action       string // actionname in long form includes domain & actor $domain.$actor.$action
	args         Params
	result       Params
	state        ActionJobState
	start        time.Time
	end          time.Time
	grace_period u32 // wait till next run
	error        string
	timeout      u32    // time in seconds, 2h is maximum
	src_twinid   u32    // which twin is responsible for executing on behalf of actor
	src_action   string // unique actor id, runs on top of twin
	dependencies []string
}

// An internal struct for representing failed jobs.
pub struct JobError {
	Error
pub mut:
	msg      string
	job_guid string
}

// Returns a human readable job error message.
pub fn (err JobError) msg() string {
	return 'Job Error: Job ${err.job_guid} failed with error: ${err.msg}'
}
