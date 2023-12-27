module osal

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import json
import os
import time
// import io.util

pub struct JobError {
	Error
mut:
	job        Job
	error_type ErrorType
}

pub enum ErrorType {
	exec
	timeout
	args
}

fn (err JobError) msg() string {
	if err.error_type == .args {
		return 'Error in arguments:\n${err.job.cmd}'
	}
	if err.error_type == .timeout {
		return 'Execution failed timeout\n${err.job}'
	}
	mut msg := 'Execution failed with code ${err.job.exit_code}\n'
	if err.job.cmd.scriptpath.len > 0 {
		msg += '\nscript path:${err.job.cmd.scriptpath}'
	}
	if err.job.output.len > 0 {
		msg += "\n\n## stdout:\n${err.job.output.join_lines()}"
	}
	if err.job.error.len > 0 {
		msg += "\n\n## stderr:\n${err.job.error.join_lines()}"
	}
	return msg
}

fn (err JobError) code() int {
	if err.error_type == .timeout {
		return 9999
	}
	return err.job.exit_code
}

@[params]
pub struct Command {
pub mut:
	name               string // to give a name to your command, good to see logs...
	cmd                string
	description        string
	timeout            int  = 3600 // timeout in sec
	stdout             bool = true
	stdout_log         bool = true
	raise_error        bool = true // if false, will not raise an error but still error report
	ignore_error       bool // means if error will just exit and not raise, there will be no error reporting
	work_folder        string // location where cmd will be executed
	environment        map[string]string // env variables
	ignore_error_codes []int
	scriptpath         string // is the path where the script will be put which is executed
	scriptkeep         bool   // means we don't remove the script
	debug              bool   // if debug will put +ex in the script which is being executed and will make sure script stays
	shell              bool   // means we will execute it in a shell interactive
	retry              int
	interactive        bool = true // make sure we run in non interactive way
	async              bool
	runtime            RunTime
}

pub enum JobStatus {
	init
	running
	error_exec
	error_timeout
	error_args
	done
}

pub enum RunTime {
	bash
	python
	bashshell
}

pub struct Job {
pub mut:
	start     time.Time
	end       time.Time
	cmd       Command
	output    []string
	error     []string
	exit_code int
	status    JobStatus
	process   ?&os.Process @[skip; str: skip]
	runnr     int // nr of time it runs, is for retry
}

// cmd is the cmd to execute can use ' ' and spaces .
// if \n in cmd it will write it to ext and then execute with bash .
// if die==false then will just return returncode,out but not return error .
// if stdout will show stderr and stdout .
// .
// if cmd starts with find or ls, will give to bash -c so it can execute .
// if cmd has no path, path will be found .
// .
// Command argument: .
//```
// name                             string // to give a name to your command, good to see logs...
// cmd                              string
// description                      string
// timeout                          int  = 3600 // timeout in sec
// stdout                           bool = true
// stdout_log                       bool = true
// raise_error                      bool = true // if false, will not raise an error but still error report
// ignore_error                     bool // means if error will just exit and not raise, there will be no error reporting
// work_folder                      string // location where cmd will be executed
// environment                      map[string]string // env variables
// ignore_error_codes               []int
// scriptpath                       string // is the path where the script will be put which is executed
// scriptkeep                       bool   // means we don't remove the script
// debug                            bool   // if debug will put +ex in the script which is being executed and will make sure script stays
// shell                            bool   // means we will execute it in a shell interactive
// retry                            int
// interactive 					 	bool = true // make sure we run on non interactive way
// async							 bool
// runtime							 RunTime (.bash, .python)
//
// returns Job:
// start  time.Time
// end    time.Time
// cmd    Command
// output []string
// error    []string
// exit_code int
// status JobStatus
// process os.Process
//```
// return Job .
pub fn exec(cmd Command) !Job {
	mut job := Job{
		cmd: cmd
	}
	job.start = time.now()

	if job.cmd.debug {
		job.cmd.stdout = true
		console.print_header(' execute: \n${job.cmd}')
	}

	if cmd.shell {
		console.print_header(' cmd shell')
		process_args := job.cmd_to_process_args()!
		if cmd.retry > 0 {
			job.error << 'cmd retry cannot be > 0 if shell used'
			job.exit_code = 999
			return JobError{
				job: job
				error_type: .args
			}
		}
		os.execvp(process_args[0], process_args[1..process_args.len])!
		return job
	}
	if !cmd.async {
		job.execute_retry()!
	}
	return job
}

// execute the job and wait on result
// will retry as specified
pub fn (mut job Job) execute_retry() ! {
	for _ in 0 .. job.cmd.retry + 1 {
		job.execute()!
		job.wait()!
		if job.status != .running {
			job.close()!
			return
		}
	}
	job.close()!
}

// execute the job, start process, process will not be closed .
// important you need to close the process later by job.close()! otherwise we get zombie processes
pub fn (mut job Job) execute() ! {
	job.runnr += 1
	job.start = time.now()
	job.status = .running
	// start:=job.start.unix_time()

	process_args := job.cmd_to_process_args()!

	// println(" - process execute ${process_args[0]}")
	mut p := os.new_process(process_args[0])

	if job.cmd.work_folder.len > 0 {
		p.set_work_folder(job.cmd.work_folder)
	}
	if job.cmd.environment.len > 0 {
		p.set_environment(job.cmd.environment)
	}
	p.set_redirect_stdio()
	// println("process setargs ${process_args[1..process_args.len]}")
	p.set_args(process_args[1..process_args.len])
	if job.cmd.stdout{
		println("")
	}
	p.run()
	job.process = p
	// println( p.is_alive() )
	// time.sleep(1000 * time.millisecond)
	// println( p.is_alive() )
	// println("running?")
}

pub struct ReceiveResult {
pub mut:
	output string
	error  string
	done   bool
}

fn (mut job Job) read() !ReceiveResult {
	mut result := ReceiveResult{}

	mut p := job.process or { return error('there is not process on job') }

	out_std := p.pipe_read(.stdout) or { '' }
	if out_std.len > 0 {
		if job.cmd.stdout {
			console.print_stdout(out_std)
		}
		job.output << out_std.split_into_lines()
		result.error = out_std
	}
	out_error := p.pipe_read(.stderr) or { '' }
	if out_error.len > 0 {
		if job.cmd.stdout {
			console.print_stderr(out_error)
		}
		job.error << out_error.split_into_lines()
		result.error = out_error
	}
	return result
}

// process (read std.err and std.out of process)
pub fn (mut job Job) process() !ReceiveResult {
	// $if debug{println(" - job process: $job")}
	if job.status == .init {
		job.execute()!
	}
	mut p := job.process or { return error('there is not process on job') }

	mut result := job.read()!
	if p.is_alive() {
		// result=job.read()!
		if time.now().unix_time() > job.start.unix_time() + job.cmd.timeout * 1000 {
			p.signal_pgkill()
			p.close()
			job.exit_code = 9999
			job.end = time.now()
			job.status = .error_timeout
			if job.cmd.raise_error {
				return JobError{
					job: job
					error_type: .timeout
				}
			}
		}
		// println("4")
		return result
	}
	// println(" - process stopped")
	job.status = .done
	result.done = true
	if p.code > 0 {
		// println(" ########## Process CODE IS > 0")
		job.exit_code = p.code
		job.status = .error_exec
		job.cmd.scriptkeep = true
		p.signal_pgkill()
		p.close()
	} else {
		// println('wait')
		p.wait()
		p.close()
	}
	return result
}

// wait till the job finishes or goes in error
pub fn (mut job Job) wait() ! {
	if job.status != .running && job.status != .init {
		return error('can only wait for running job')
	}
	mut counter := 0
	for {
		counter += 1
		// println("loop $counter")
		result := job.process()!
		// println(result)
		if result.done {
			job.status = .done
			// println("wait done")
			return
		}
		time.sleep(100 * time.millisecond)
	}
}

// will wait & close
pub fn (mut job Job) close() ! {
	mut p := job.process or { return error('there is not process on job') }

	p.signal_pgkill()
	p.wait()
	p.close()
	job.end = time.now()
	if job.exit_code > 0 && job.exit_code !in job.cmd.ignore_error_codes {
		if !job.cmd.ignore_error {
			errorpath := job.cmd.scriptpath.all_before_last('.sh') + '_error.json'
			errorjson := json.encode_pretty(job)
			os.write_file(errorpath, errorjson) or {
				msg := 'cannot write errorjson to ${errorpath}'
				return error(msg)
			}

			errorpath2 := job.cmd.scriptpath.all_before_last('.sh') + '_error.log'
			mut errortxt := '# ERROR:\n\n'
			errortxt += job.cmd.cmd + '\n'
			errortxt += '## OUTPUT:\n\n'
			errortxt += job.output.join_lines()
			os.write_file(errorpath2, errortxt) or {
				msg := 'cannot write error to ${errorpath2}'
				return error(msg)
			}

			je := JobError{
				job: job
				error_type: .exec
			}
			if job.cmd.stdout {
				println('Job Error')
				println(je.msg())
			}
			if job.cmd.raise_error {
				return je
			}
		}
	}

	if job.exit_code == 0 && job.cmd.scriptkeep == false && os.exists(job.cmd.scriptpath) {
		// println(job.cmd.scriptpath)	
		os.rm(job.cmd.scriptpath)!
	}
	if job.cmd.ignore_error == false && job.cmd.scriptkeep == false && os.exists(job.cmd.scriptpath) {
		os.rm(job.cmd.scriptpath)!
	}
	// job.status = .done

	if job.cmd.raise_error && job.exit_code > 0 {
		return JobError{
			job: job
			error_type: .exec
		}
	}
}

// process commands to arguments which can be given to a process manager
// will return temporary path and args for process
fn (mut job Job) cmd_to_process_args() ![]string {
	if job.cmd.runtime == .bashshell {
		// bash -s 'echo ready'
		// return ['/bin/bash', '-s', "'echo **READY**'"]
		return ['/opt/homebrew/bin/python3']
	}
	// all will be done over filessytem now
	mut cmd := texttools.dedent(job.cmd.cmd)
	if !cmd.ends_with('\n') {
		cmd += '\n'
	}

	if job.cmd.environment.len > 0 {
		mut cmdenv := ''
		for key, val in job.cmd.environment {
			cmdenv += "export ${key}='${val}'\n"
		}
		cmd = cmdenv + '\n' + cmd
		// process.set_environment(args.environment)
	}

	// use bash debug and die on error features
	mut firstlines := '#!/bin/bash\n'
	if !job.cmd.ignore_error {
		firstlines += 'set -e\n' // exec 2>&1\n
	} else {
		firstlines += 'set +e\n' // exec 2>&1\n
	}
	if job.cmd.debug {
		firstlines += 'set -x\n' // exec 2>&1\n
	}

	if !job.cmd.interactive && job.cmd.runtime == .bash {
		// firstlines += 'export DEBIAN_FRONTEND=noninteractive TERM=xterm\n\n'
		firstlines += 'export DEBIAN_FRONTEND=noninteractive\n\n'
	}

	cmd = firstlines + '\n' + cmd

	scriptpath := if job.cmd.scriptpath.len > 0 {
		job.cmd.scriptpath
	} else {
		''
	}
	job.cmd.scriptpath = pathlib.temp_write(text: cmd, path: scriptpath, name: job.cmd.name) or {
		return error('error: cannot write script to execute: ${err}')
	}

	os.chmod(job.cmd.scriptpath, 0o777)!
	// println(" - scriptpath: ${job.cmd.scriptpath}")
	return ['/bin/bash', job.cmd.scriptpath]
}

// shortcut to execute a job silent
pub fn execute_silent(cmd string) !string {
	job := exec(cmd: cmd, stdout: false)!
	return job.output.join_lines()
}

// shortcut to execute a job to stdout
pub fn execute_stdout(cmd string) !string {
	job := exec(cmd: cmd, stdout: true)!
	return job.output.join_lines()
}

// shortcut to execute a job interactive means in shell
pub fn execute_interactive(cmd string) ! {
	exec(cmd: cmd, stdout: true, shell: true)!
}

pub fn cmd_exists(cmd string) bool {
	res := os.execute('which ${cmd}')
	if res.exit_code > 0 {
		return false
	}
	return true
}

// cmd is the cmd to execute can use ' ' and spaces
// if \n in cmd it will write it to ext and then execute with bash
// if die==false then will just return returncode,out but not return error
// if stdout will show stderr and stdout
//
// if cmd starts with find or ls, will give to bash -c so it can execute
// if cmd has no path, path will be found
// $... are remplaced by environment arguments TODO:implement
//
// Command argument:
//   cmd string
//   timeout int = 600
//   stdout bool = true
//   die bool = true
//	 debug bool
//
// return what needs to be executed can give it to bash -c ...
pub fn exec_string(cmd Command) !string {
	mut job := Job{
		cmd: cmd
	}
	job.start = time.now()
	process_args := job.cmd_to_process_args()!
	return process_args[process_args.len - 1]
}
