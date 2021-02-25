module builder

// long running process
pub struct Process {
	cmd        string
	arguments  []string
	// timeout in seconds, default 5 min
	timeout    int = 300
	retry      int = 1
	stdout_log bool = true
	stderr_log bool = true
pub mut:
	time_start int
	time_stop  int
	stdout     string
	sterr      string
	state      ProcessState
}

enum ProcessState {
	ok
	error
	halted
}

// make sure all is there so the process can start, not used 
pub fn (mut process Process) prepare(wish Wish) ? {
}

// start the process
pub fn (mut process Process) start(wish Wish) ? {
}

// stop the process
pub fn (mut process Process) stop(wish Wish) ? {
}

// check if process is still running
pub fn (mut process Process) check(wish Wish) ? {
}

// kill if needed, restart
pub fn (mut process Process) recover(wish Wish) ? {
}

// return info about process
pub fn (mut process Process) info(wish Wish) ? {
}

// stop process
pub fn (mut process Process) halt(wish Wish) ? {
}

// same as stop
pub fn (mut process Process) delete(wish Wish) ? {
	return process.stop(wish)
}
