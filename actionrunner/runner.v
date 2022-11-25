module actionrunner

//is the one running in a thred
[heap]
pub struct Runner {
mut:
	channel chan &ActionJob
	channel_log chan string
	jobcurrent []ActionJob
}

//return reference to the current job
pub fn (mut runner Runner) job() ActionJob {
	if runner.jobcurrent.len != 1{
		panic("current jobs in runner should be 1 when calling log")
	}
	return runner.jobcurrent[0]
}

// ? should running and done also be implemented this way?
pub fn (mut runner Runner) error(msg string) {
	mut job := runner.job()
	job.state = .error
	job.error = "$msg"
	// runner.done()
}

// messages that current job is running
pub fn (mut runner Runner) running() {
	runner.channel_log <- "${runner.job().id}:running"
}

// ? returns job when job is done
pub fn (mut runner Runner) done() {
	// runner.channel <- &runner.jobcurrent[0]
	runner.channel_log <- "${runner.job().id}:done"
	runner.jobcurrent = []ActionJob{} //empty
}

pub fn (mut runner Runner) log(msg string) {
	runner.channel_log <- "${runner.job().id}:${msg}"
}