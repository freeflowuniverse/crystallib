module process

import os
import time
import freeflowuniverse.crystallib.texttools
// import io.util
import json

pub struct Command {
pub mut:
	cmd        string
	timeout    int  = 1200
	stdout     bool = true
	stdout_log bool = true
	debug      bool 
	die        bool = true
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
pub fn execute_job(cmd Command) ?Job {
	mut cmd_obj := cmd
	// println("CMD:$cmd_obj.cmd")
	mut out := ''
	mut job := Job{}
	job.cmd = cmd
	job.start = time.now()
	mut cleanuppath := ''
	mut args := []string{}
	cleanuppath, args = cmd_to_args(cmd_obj.cmd)?

	if cmd_obj.debug {
		cmd_obj.stdout = true
		println('execute: $job')
	}

	mut p := os.new_process(args[0])
	p.set_redirect_stdio()

	p.set_args(args[1..args.len])
	p.run()
	if p.is_alive() {
		start := time.now().unix_time()
		for {
			out = p.stdout_read()
			// out_err = p.stderr_read()
			if out != '' {
				if cmd_obj.stdout {
					println(out)
				}
				if cmd_obj.stdout_log {
					job.output += out
				}
			}
			if time.now().unix_time() > start + cmd_obj.timeout {
				job.exit_code = 100
				job.error = 'timeout'
				break
			}

			if !p.is_alive() {
				break
			}
		}
	}
	if p.code > 0 {
		job.exit_code = p.code
	}

	job.end = time.now()

	if job.exit_code > 0 {
		if job.error == '' {
			job.error = 'unknown'
		}
		errorpath := cleanuppath.all_before_last('.sh') + '.json'
		errorjson := json.encode_pretty(job)
		os.write_file(errorpath, errorjson) or {
			msg := "cannot write errorjson to $errorpath"
			return error(msg)
		}
		if cmd_obj.die {
			// if cleanuppath!=""{os.rm(cleanuppath) or {}}
			msg := 'Cannot execute:\n$job'
			println(msg)
			return error(msg)
		}
	} else {
		if cleanuppath != '' {
			if os.exists(cleanuppath){
				os.rm(cleanuppath)?
			}
		}
	}
	return job
}

// write temp file and return path
fn temp_write(text string) ?string {
	mut tmpdir := '/tmp'
	// if 'TMPDIR' in os.environ() {
	// 	tmpdir = os.environ()['TMPDIR'] or {
	// 		panic('cannot find TMPDIR in os.environment variables.')
	// 	}
	// }
	t := time.now().format_ss_milli().replace(' ', '-')
	mut tmppath := '$tmpdir/execscripts/${t}.sh'
	if !os.exists('$tmpdir/execscripts/') {
		os.mkdir('$tmpdir/execscripts') or {
			return error('Cannot create $tmpdir/execscripts,$err')
		}
	}
	if os.exists(tmppath) {
		for i in 1 .. 200 {
			// println(i)
			tmppath = '$tmpdir/execscripts/{$t}_${i}.sh'
			if !os.exists(tmppath) {
				break
			}
			// TODO: would be better to remove older files, e.g. if older than 1 day, remove
			if i > 99 {
				// os.rmdir_all('$tmpdir/execscripts')?
				// return temp_write(text)
				panic("should not get here, can't find temp file to write for process job.")
			}
		}
	}
	os.write_file(tmppath, text)?
	return tmppath
}

fn check_write(text string) bool {
	if texttools.check_exists_outside_quotes(text, ['<', '>', '|']) {
		return true
	}
	if text.contains('\n') {
		return true
	}
	return false
}

// process commands to arguments which can be given to a process manager
// will return temporary path and args
fn cmd_to_args(cmd string) ?(string, []string) {
	mut cleanuppath := ''
	mut text := cmd

	// all will be done over filessytem now
	text = texttools.dedent(text)
	if !text.ends_with('\n') {
		text += '\n'
	}
	text = '#!/bin/bash\nset -e\n$text'
	cleanuppath = temp_write(text) or { return error('error: cannot write $err') }
	return cleanuppath, ['/bin/bash', '-c', '/bin/bash $cleanuppath 2>&1']

	// if text.contains('&&') && !check_write(text) {
	// 	text = text.replace('&&', '\n')
	// 	text = 'set -e\n$text'
	// }

	// if check_write(text) {
	// 	// will write temp file which can then be executed

	// 	text = texttools.dedent(text)
	// 	if !text.ends_with('\n') {
	// 		text += '\n'
	// 	}
	// 	text = '#!/bin/bash\nset -ex\n\n$text'
	// 	// println("write\n$text")
	// 	cleanuppath = temp_write(text) or { return error('error: cannot write $err') }
	// 	return cleanuppath, ['/bin/bash', '2>&1', cleanuppath]
	// } else {
	// 	for x in ['find', 'ls'] {
	// 		if text.starts_with('$x ') {
	// 			if '"' in text {
	// 				return error('Cannot embed string in \"\"  because is already using in $text')
	// 			}
	// 			// text = 'bash -c \"$text\"'
	// 			return cleanuppath, ['/bin/bash', '-c', text, '2>&1']
	// 		}
	// 	}
	// }

	// is still giving issues prob easier for now to only use first part and then all the rest together, lets see what happens now
	// mut args := texttools.cmd_line_args_parser(text)?

	// splitted := text.split_nth(' ', 2)
	// mut args := [splitted[0], splitted[1]]

	// // get the path of the file
	// if !args[0].starts_with('/') {
	// 	args[0] = os.find_abs_path_of_executable(args[0]) ?
	// }
	// return cleanuppath, args
}

pub fn execute_silent(cmd string) ?string {
	job := execute_job(cmd: cmd, stdout: false)?
	return job.output
}

pub fn execute_stdout(cmd string) ?string {
	job := execute_job(cmd: cmd, stdout: true)?
	return job.output
}

pub fn execute_interactive(cmd string) ? {
	mut cleanuppath := ''
	mut args := []string{}

	cleanuppath, args = cmd_to_args(cmd)?

	os.execvp(args[0], args[1..args.len])?

	if cleanuppath != '' {
		os.rm(cleanuppath) or {}
	}
}

// check if platform is osx
pub fn is_osx() bool {
	p := os.user_os()
	return p.contains('macos')
}

// check if platform is ubuntu
pub fn is_ubuntu() bool {
	p := os.user_os()
	println(p)
	panic('is_osx needs to be implemented')
}
