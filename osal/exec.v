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
	stdout             bool = true
	checkkey           string // if used will use this one in stead of hash of cmd, to check if was executed already
	tmpdir             string
	environment        map[string]string
	ignore_error_codes []int
	retry_max          int = 1 // how may times maximum to retry
	retry_period       int = 100 // sleep in between retry in milliseconds
	retry_timeout      int = 2 // timeout for al the tries together	in milliseconds
}

// TODO: document properly
// supports multiline
pub fn (mut o Osal) exec(args ExecArgs) !string {
	mut cmd := args.cmd
	mut now_epoch := time.now().unix_time()
	mut now_str := now_epoch.str()
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
		if args.period == 0 {
			o.logger.info('exec cmd:${description}: was already done, period indefinite.')
			return o.done_get('exec_${hhash}') or { '' }
		}
		nodedone := o.done_get_str('exec_${hhash}')
		splitted := nodedone.split('|')
		if splitted.len != 2 {
			return error("Cannot return from done on exec needs to have |, now \n'${nodedone}' ")
		}
		exec_last_time := splitted[0].int()
		lastoutput := splitted[1]
		if exec_last_time <= 10000 {
			return error('Last time should  be more then 10000')
		}
		assert exec_last_time > 10000
		o.logger.info('check exec cmd:${cmd}: time:${exec_last_time}')
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			o.logger.info('exec cmd:${description}: was already done, period ${hours} h')
			return lastoutput
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
	cmd = "mkdir -p ${tmpdir} && cd ${tmpdir} && export TMPDIR='${tmpdir}' && bash ${r_path}"
	if args.remove_installer {
		cmd += ' && rm -f ${r_path}'
	}
	o.logger.info('exec cmd:${cmd}')
	old_environment := o.env_get_all()
	if args.environment.len > 0 {
		o.env_set_all(env: args.environment)
	}
	res := os.execute(cmd)
	o.env_set_all(env: old_environment)
	if res.exit_code != 0 {
		return error('Execution failed with exit code ${res.exit_code}' +
			'\noriginal cmd:\n${args.cmd}')
	}

	o.done_set('exec_${hhash}', '${now_str}|${res.output}')!
	return res.output
}
