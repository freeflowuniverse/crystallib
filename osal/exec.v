module installers

//following functions are set of utilities to make our life easy, use vlang as constructs (not the builder)

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
	ignore_error_codes []int
 	retry_max 		   int = 1 		//how may times maximum to retry
  	retry_period       int = 100	//sleep in between retry in milliseconds
	retry_timeout 	   int = 2	    //timeout for al the tries together	in milliseconds
}


//TODO: document properly
// supports multiline
pub fn exec(args ExecArgs) !string {
	//TODO: implement without node builder, use redis for state
	mut args := args_
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
	if !args.reset && done_exists('exec_${hhash}') {
		if args.period == 0 {
			println('   - exec cmd:${description} on ${name}: was already done, period indefinite.')
			return done_get('exec_${hhash}') or { '' }
		}
		nodedone := done_get_str('exec_${hhash}')
		splitted := nodedone.split('|')
		if splitted.len != 2 {
			panic("Cannot return from done on exec needs to have |, now \n'${nodedone}' ")
		}
		exec_last_time := splitted[0].int()
		lastoutput := splitted[1]
		assert exec_last_time > 10000
		// println(args)
		// println("   - check exec cmd:$cmd on $name: time:$exec_last_time")
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			println('   - exec cmd:${description} on ${name}: was already done, period ${hours} h')
			return lastoutput
		}
	}

	if args.tmpdir.len == 0 {
		if 'TMPDIR' !in environment {
			args.tmpdir = '/tmp'
		} else {
			args.tmpdir = environment['TMPDIR']
		}
	}
	r_path := '${args.tmpdir}/installer.sh'
	file_write(r_path, cmd)!
	cmd = "mkdir -p ${args.tmpdir} && cd ${args.tmpdir} && export TMPDIR='${args.tmpdir}' && bash ${r_path}"
	if args.remove_installer {
		cmd += ' && rm -f ${r_path}'
	}
	// println("   - exec cmd:$cmd on $name")
	res := exec(cmd) or { return error(err.msg() + '\noriginal cmd:\n${args.cmd}') }

	done_set('exec_${hhash}', '${now_str}|${res}')!
	return res
}

