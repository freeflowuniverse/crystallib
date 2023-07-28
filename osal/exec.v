module osal

import freeflowuniverse.crystallib.texttools
import crypto.md5
import os
import time

// following functions are set of utilities to make our life easy, use vlang as constructs (not the builder)

[params]
pub struct ExecArgs {
pub mut:
	cmd                string
	period             int  // period in which we check when this was done last, if 0 then period is indefinite
	reset              bool = true // means do again or not
	remove_installer   bool = true // delete the installer
	description        string
	checkkey           string // if used will use this one in stead of hash of cmd, to check if was executed already
	tmpdir             string
	environment        map[string]string
	ignore_error_codes []int
	retry_max          u8 = 1 // how may times maximum to retry
	retry_period       int = 100 // sleep in between retry in milliseconds
	retry_timeout      int = 2000 // timeout for al the tries together in milliseconds, if this value is 0 it will wait indefinite
}

pub fn (mut o Osal) cmd_exists(cmd string) bool {
	o.exec(cmd: 'which ${cmd}', retry_max: 0) or {
		return false
	}
	return true
}

// Executes the provided command in a bash script using the environment variables. It retries the amount of times specified in the arguments if the command failed and fails if the command took longer then the retry_timeout. 
// The output of a successful command is returned and cached in redis. The cached value will be returned if the same command is executed again and if arguments allow so.
pub fn (mut o Osal) exec(args ExecArgs) !string {
	mut cmd := args.cmd
	mut now_epoch := time.now().unix_time()

	if cmd.contains('\n') {
		cmd = texttools.dedent(cmd)
	}

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

	if !args.reset && o.done_exists('exec_${hhash}') {
		nodedone := o.done_get_str('exec_${hhash}')
		splitted := nodedone.split('|')
		if splitted.len != 2 {
			return error("Cannot return from done on exec needs to have |, now \n'${nodedone}' ")
		}
		exec_last_time := splitted[0].int()
		lastoutput := splitted[1]
		if args.period == 0 {
			o.logger.info('exec cmd:${description}: was already done, period indefinite.')
			return lastoutput
		}
		if exec_last_time <= 10000 {
			return error('Last time should  be more then 10000')
		}
		o.logger.info('check exec cmd:${cmd}: time:${exec_last_time}')
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			o.logger.info('exec cmd:${description}: was already done, period ${hours} h')
			return lastoutput
		} else {
			o.logger.debug('exec cmd:${description}: was already done but it was too long ago, doing it agian')
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

	r_path := '${tmpdir}/installer.sh'
	o.file_write(r_path, cmd)!
	if args.remove_installer {
		defer {
			os.rm(r_path) or { }
		}
	}
	os.chmod(r_path, 0o777)!

	time_started := time.now()
	mut err := ""
	mut err_code := 0
	for x in 0..args.retry_max+1 {
		mut process := os.new_process("/bin/bash")
		process.set_args([r_path])
		process.set_work_folder(tmpdir)
		process.set_redirect_stdio()
		if args.environment.len > 0 {
			process.set_environment(args.environment)	
		}
		
		process.run()
		for args.retry_timeout > 0 && process.is_alive() {
			if time.now() - time_started >= time.millisecond * args.retry_timeout {
				process.signal_kill()
				return error('Execution failed due to timeout (${args.retry_timeout})\noriginal cmd:\n${args.cmd}')
			} 
			time.sleep(time.millisecond * 100)
		}
		process.wait()
		err = process.stderr_read()
		if process.code == 0 || process.code in args.ignore_error_codes {
			res := process.stdout_read()
			o.done_set('exec_${hhash}', '${time.now().unix_time().str()}|${res}')!
			return res
		} else {
			err_code = process.code
			attempts := if args.retry_max > 0 { " (attempt nr ${x+1})" } else { "" }
			o.logger.error("Execution failed with code ${process.code}${attempts}: ${err}")
		}
	}

	return error('Execution failed with code ${err_code} (retried ${args.retry_max} times):\nerr:"${err}"\noriginal cmd:\n${args.cmd}')
}
