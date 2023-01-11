module rmbclient
import freeflowuniverse.crystallib.params { Params }
import time


// return true if we didn't reach timeout yet
pub fn (mut job ActionJob) check_timeout_ok() bool {
	if job.timeout == 0 {
		return true
	}
	//TODO: implement/check
	deadline := job.start.unix_time() + i64(job.timeout)
	if deadline < time.now().unix_time() {
		return false
	}
	return true
}


