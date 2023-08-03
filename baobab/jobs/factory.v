module jobs

import freeflowuniverse.crystallib.params { Params }
import rand
import time

// Arguments for creating a new job
[params]
pub struct JobNewArgs {
pub mut:
	twinid       u32
	action       string
	args         Params
	actionsource string
	src_twinid   u32
	timeout      f64
}

// Creates new actionjob
pub fn new(args JobNewArgs) !ActionJob {
	mut j := ActionJob{
		guid: rand.uuid_v4()
		twinid: args.twinid
		action: args.action
		args: args.args
		start: time.now()
		src_action: args.actionsource
		src_twinid: args.src_twinid
	}
	return j
}
