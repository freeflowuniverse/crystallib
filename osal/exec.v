module osal

import os
import time
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib
// import io.util
import json

pub struct JobError {
	Error
mut:
	job			Job
	error_type  ErrorType
}

pub enum ErrorType{
	timeout
	args
}

fn (err JobError) msg() string {
	if err.error_type == .args {
		return 'Error in arguments:\n${err.job.cmd}'
	}
	if err.error_type == .timeout {
		return 'Execution failed timeout\n${err.job.cmd}'
	}
	mut msg := 'Execution failed with code ${err.job.exit_code}\n${err.job.error}\n${err.job.cmd}'
	if err.job.cmd.scriptpath.len > 0 {
		msg += '\nscript path:${err.job.cmd.scriptpath}'
	}
	return msg
}

fn (err JobError) code() int {
	if err.error_type == .timeout{
		return 9999
	}
	return err.job.exit_code
}


[params]
pub struct Command {
pub mut:
	cmd        string
	description 	string
	timeout    int = 3600
	stdout     bool
	stdout_log bool = true
	die        bool = true
	work_folder string //location where cmd will be executed
	environment map[string]string //env variables
	ignore_error_codes []int
	scriptpath		   string //is the path where the script will be put which is executed
	debug			   bool //if debug will put +ex in the script which is being executed and will make sure script stays
	shell			   bool //means we will execute it in a shell interactive
	retry			int

}

pub struct Job {
pub mut:
	start     time.Time
	end       time.Time
	cmd       Command
	output    string
	error     string
	exit_code int
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
// returns Job:
//     start time.Time
//     end time.Time
//     cmd Command (links to the Command argument)
//     output string
//     error string
//     exit_code int  (return code)
//
// return Job
// out is the output
pub fn exec(cmd Command) !Job {
	mut job := Job{cmd:cmd}
	job.start = time.now()
	process_args := job.cmd_to_process_args()!
	mut logger := get_logger()
	defer {
		if os.exists(job.cmd.scriptpath) {
			os.rm(job.cmd.scriptpath) or {panic("cannot remove ${job.cmd.scriptpath}")}
		}
	}
	if job.cmd.debug {
		job.cmd.stdout = true
		println('execute: ${job}')
	}

	if cmd.shell{

		if cmd.retry>0{
			job.error = "cmd retry cannot be >0 if shell used"
			return JobError{job:job,error_type:.args}
		}

		os.execvp(process_args[0], process_args[1..process_args.len])!			
	}else{
		start := time.now().unix_time()		
		for x in 0..job.cmd.retry+1{		
			mut p := os.new_process(process_args[0])
			defer {
				p.close()
			}		
			if job.cmd.work_folder.len>0{
				p.set_work_folder(job.cmd.work_folder)
			}			
			if job.cmd.environment.len > 0 {
				p.set_environment(job.cmd.environment)
			}
			p.set_redirect_stdio()

			p.set_args(process_args[1..process_args.len])
			p.run()
			if p.is_alive() {
				for {
					out := p.stdout_read()
					// out_err = p.stderr_read(), we did 2>&1 to make sure stderr goes to stdout
					if out != '' {
						if job.cmd.stdout {
							println(out)
						}
						if job.cmd.stdout_log {
							job.output += out
						}
					}
					if time.now().unix_time() > start + job.cmd.timeout {
						job.exit_code = 9999
						job.end = time.now()
						return JobError{job:job,error_type:.timeout}
					}
					if !p.is_alive() {
						break
					}
				}
			}		
			if p.code > 0 {
				job.exit_code = p.code
				if job.cmd.retry>0 && x < job.cmd.retry {
					time.sleep( time.millisecond * 100) //wait 0.1 sec
				}
				// p.close()
			}else{
				break //go out of retry loop
			}
		}
	}
	
	job.end = time.now()

	if job.exit_code > 0 && !(job.exit_code in job.cmd.ignore_error_codes){

		if job.cmd.die {

			if job.error == '' {
				job.error = 'unknown'
			}

			errorpath := job.cmd.scriptpath.all_before_last('.sh') + '.json'
			errorjson := json.encode_pretty(job)
			os.write_file(errorpath, errorjson) or {
				msg := 'cannot write errorjson to ${errorpath}'
				return error(msg)
			}

			if job.cmd.stdout {
				println("Job Error")
			}			
			je := JobError{job:job,error_type:.timeout}
			println(je.msg())
			return je
		}
	} else {
		if !cmd.debug{
			if os.exists(job.cmd.scriptpath) {
				os.rm(job.cmd.scriptpath)!
			}
		}			
	}
	return job
}


// fn check_write(text string) bool {
// 	if texttools.check_exists_outside_quotes(text, ['<', '>', '|']) {
// 		return true
// 	}
// 	if text.contains('\n') {
// 		return true
// 	}
// 	return false
// }

// process commands to arguments which can be given to a process manager
// will return temporary path and args for process
fn (mut job Job) cmd_to_process_args() ! []string {
	// all will be done over filessytem now
	mut cmd := texttools.dedent(job.cmd.cmd)
	if !cmd.ends_with('\n') {
		cmd += '\n'
	}	

	if job.cmd.environment.len > 0 {
		mut cmdenv:=""
		for key,val in job.cmd.environment{
			cmdenv+="export $key='$val'\n"
		}
		cmd=cmdenv+"\n"+cmd
		// process.set_environment(args.environment)
	}

	//use bash debug and die on error features
	mut firstlines:="#!/bin/bash\n"
	if job.cmd.die{
		firstlines+="set +e\n"
	}else{
		firstlines+="set -e\n"
	}
	if job.cmd.debug{
		firstlines+="set +x\n"
	}
	cmd=firstlines+"\n"+cmd

	job.cmd.scriptpath = pathlib.temp_write(text:cmd,path:job.cmd.scriptpath) or { return error('error: cannot write script to execute ${err}') }
	return  ['/bin/bash', '-c', '/bin/bash ${job.cmd.scriptpath} 2>&1']

}

//shortcut to execute a job silent
pub fn execute_silent(cmd string) !string {
	job := exec(cmd: cmd, stdout: false)!
	return job.output
}

//shortcut to execute a job to stdout
pub fn execute_stdout(cmd string) !string {
	job := exec(cmd: cmd, stdout: true)!
	return job.output
}

//shortcut to execute a job interactive means in shell
pub fn execute_interactive(cmd string) ! {
	exec(cmd: cmd, stdout: true, shell:true)!
}


pub fn cmd_exists(cmd string) bool {
	exec(cmd: 'which ${cmd}', retry: 0) or { return false }
	return true
}
