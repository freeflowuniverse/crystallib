module actionrunnerold

// is the one active in a thred
[heap]
pub struct Runner {
mut:
	channel     chan &ActionJob
	channel_ret chan &ActionJobReturn
	channel_log chan string
	jobcurrent  []ActionJob
}

// return reference to the current job
pub fn (mut runner Runner) job() &ActionJob {
	if runner.jobcurrent.len != 1 {
		panic('current jobs in runner should be 1 when calling log')
	}
	return &runner.jobcurrent[0]
}

// ? should active and done also be implemented this way?
pub fn (mut runner Runner) error(msg string) {
	return_obj := ActionJobReturn{
		job_guid: runner.job().guid
		event: .error
		error: msg
	}
	runner.channel_ret <- &return_obj
}

// sends event to schedulersession alongside actionjob
pub fn (mut runner Runner) running() {
	// todo: maybe its best to only return guid since this requires updating state in both places
	return_obj := ActionJobReturn{
		job_guid: runner.job().guid
		event: .running
	}
	runner.channel_ret <- &return_obj
}

// ? returns job when job is done
pub fn (mut runner Runner) done() {
	return_obj := ActionJobReturn{
		job_guid: runner.job().guid
		event: .ok
	} //? no result if done
	runner.channel_ret <- &return_obj
	runner.jobcurrent = []ActionJob{} // empty
}

pub fn (mut runner Runner) log(msg string) {
	runner.channel_log <- '${runner.job().guid}:${msg}'
}
