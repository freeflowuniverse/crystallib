module osal

import os
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct UserArgs {
pub mut:
	name string @[required]
}

pub fn user_exists(username string) bool {
	res := os.execute('id ${username}')
	if res.exit_code > 0 {
		console.print_debug(res.exit_code)
		// return error("cannot execute id ... code to see if username exist")
		return false
	}
	return true
}

pub fn user_id_get(username string) !int {
	res := os.execute('id ${username}')
	if res.exit_code > 0 {
		return error('cannot execute id ... code to see if username exist')
	}
	return res.output.all_before('(').all_after_first('=').int()
}

// add's a user if the user does not exist yet
pub fn user_add(args UserArgs) !int {
	if user_exists(args.name) {
		return user_id_get(args.name)!
	}
	mut cmd := ''
	platform_ := platform()
	if platform_ == .ubuntu {
		cmd = 'useradd -m ${args.name} '
	} else {
		panic('Unsupported platform for user_add')
	}
	_ := exec(cmd: cmd, timeout: 0, stdout: false)!

	return user_id_get(args.name)!
}
