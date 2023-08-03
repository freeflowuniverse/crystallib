module osal

import freeflowuniverse.crystallib.texttools
import crypto.md5
import os
import time

pub struct ExecError {
	Error
mut:
	args        ExecArgs
	script_path string
	exitcode    int
	error       string
	timeout     bool
	argserror   bool
}

fn (err ExecError) msg() string {
	if err.argserror {
		return 'Error in arguments:${err.error}\n${err.args}'
	}
	if err.timeout {
		return 'Execution failed timeout\n${err.args}'
	}
	mut msg := 'Execution failed with code ${err.exitcode}\n${err.error}\n${err.args}'
	if err.script_path.len > 0 {
		msg += '\nscript path:${err.script_path}'
	}
	return msg
}

fn (err ExecError) code() int {
	if err.timeout {
		return 9999
	}
	return err.exitcode
}

// following functions are set of utilities to make our life easy, use vlang as constructs (not the builder)

[params]
pub struct ExecArgs {
pub mut:
	cmd                string
	period             int  // period in which we check when this was done last, if 0 then period is indefinite
	reset              bool = true // means do again or not
	description        string
	checkkey           string // if used will use this one in stead of hash of cmd, to check if was executed already
	tmpdir             string
	environment        map[string]string
	ignore_error_codes []int
	ignore_errors	   bool //if set will ignore all errors (not for shell)
	silent             bool // if silent will not do logs
	stdout             bool // will print everything to output
	timeout			   u8 = 10000 //timeout default is 10 sec (is in milliseconds) is per retry, 0 means wait forever
	retry              u8   // how may times maximum to retry  (0 means just execute 1x), will only work when no shell
	retry_period       int = 100 // sleep in between retry in milliseconds
	shell			   bool  //if shell will run interactive
	path			   string //is the path where the script will be put which is executed
	debug			   bool //if debug will put +ex in the script which is being executed and will make sure script stays
}

pub fn cmd_exists(cmd string) bool {
	exec(cmd: 'which ${cmd}', retry: 0) or { return false }
	return true
}

// Executes the provided command in a bash script using the environment variables.
// It retries the amount of times specified in the arguments if the command failed and fails if the command took longer then the retry_timeout.
// The output of a successful command is returned and cached in redis.
// The cached value will be returned if the same command is executed again and if arguments allow so.
pub fn exec(args_ ExecArgs) !string {
	mut args:=args_
	mut logger := get_logger()
	mut cmd := args.cmd
	mut now_epoch := time.now().unix_time()

	if cmd.contains('\n') {
		cmd = texttools.dedent(cmd)
	}

	if args.environment.len > 0 {
		mut cmdenv:=""
		for key,val in args.environment{
			cmdenv+="export $key='$val'\n"
		}
		cmd=cmdenv+"\n"+cmd
		// process.set_environment(args.environment)
	}

	//use bash debug and die on error features
	mut firstlines:=""
	if args.ignore_errors{
		firstlines+="set -e\n"
	}else{
		firstlines+="set +e\n"
	}
	if args.debug{
		firstlines+="set +x\n"
	}
	cmd=firstlines+"\n"+cmd

	mut hhash := ''
	if args.checkkey.len > 0 {
		hhash = args.checkkey
	} else {
		hhash = md5.hexhash(cmd)
	}
	mut description := args.description
	if description == '' {
		description = cmd
		if description.contains('\n') {
			description = '\n${description}\n'
		}
	}

	if args.shell{
		args.reset=true
	}
	if !args.reset && done_exists('exec_${hhash}') {
		nodedone := done_get_str('exec_${hhash}')
		splitted := nodedone.split('|')
		if splitted.len != 2 {
			panic("Cannot return from done on exec needs to have |, now \n'${nodedone}' ")
		}
		exec_last_time := splitted[0].int()
		lastoutput := splitted[1]
		if args.period == 0 && args.silent == false {
			logger.info('exec cmd:${description}: was already done, period indefinite.')
			return lastoutput
		}
		if exec_last_time <= 10000 {
			panic('Last time should  be more then 10000')
		}
		logger.info('check exec cmd:${cmd}: time:${exec_last_time}')
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			if args.silent == false {
				logger.info('exec cmd:${description}: was already done, period ${hours} h')
			}
			return lastoutput
		} else {
			if args.silent == false {
				logger.info('exec cmd:${description}: was already done but it was too long ago, doing it agian')
			}
		}
	}

	mut tmpdir := '/tmp'
	if args.tmpdir.len != 0 {
		if 'TMPDIR' in args.environment {
			tmpdir = args.environment['TMPDIR']
		} else {
			tmpdir = '/tmp'
		}
	}


	mut r_path := '${tmpdir}/exec.sh'
	if args.path.len>0{
		r_path=args.path
	}
	file_write(r_path, cmd)!
	if ! args.debug {
		defer {
			os.rm(r_path) or {}
		}
	}
	os.chmod(r_path, 0o777)!

	if args.shell {
		//should run interactive
		os.execvp("/bin/bash",[r_path])!
		return ""
	}else{
		//normal execution as subprocess, not in shell
		time_started := time.now()
		mut err := ''
		mut err_code := 0
		for x in 0 .. args.retry + 1 {
			mut process := os.new_process('/bin/bash')
			process.set_args([r_path])
			process.set_work_folder(tmpdir)
			process.set_redirect_stdio()
			if args.environment.len > 0 {
				process.set_environment(args.environment)
			}

			process.run()
			for args.timeout > 0 && process.is_alive() {
				if time.now() - time_started >= time.millisecond * 1000 * args.timeout {
					process.signal_kill()
					return ExecError{
						timeout: true
						args: args
					}
				}
				time.sleep(time.millisecond * 100)
			}
			// URGENT: we need solution to print while we are waiting, need better solution for reading stdout, needs to be in loop of above is_alive
			// ANSWER: I agree, we might want to look at using baobab here then.
			process.wait()
			err = process.stderr_read()
			if process.code == 0 || process.code in args.ignore_error_codes {
				res := process.stdout_read()
				if args.silent == false && args.stdout == true { // TODO: make sure happens while process active
					logger.info('Output from execution of command "${args.description}"')
				}
				done_set('exec_${hhash}', '${time.now().unix_time().str()}|${res}')!
				return res
			} else {
				err_code = process.code
				attempts := if args.retry > 0 { ' (attempt nr ${x + 1})' } else { '' }
				if args.silent == false {
					logger.error('Execution failed with code ${process.code}${attempts}: ${err}')
				}
			}
		}		
		return ExecError{
			error: err
			args: args
			exitcode: err_code
			script_path: r_path
		}
	}


}
