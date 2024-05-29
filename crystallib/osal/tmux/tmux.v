module tmux

import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.session
import os
import time
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Tmux {
pub mut:
	sessions  []&Session
	sessionid string // unique link to job
}

@[params]
pub struct TmuxNewArgs {
	sessionid string
}

// return tmux instance
pub fn new(args TmuxNewArgs) !Tmux {
	mut t := Tmux{
		sessionid: args.sessionid
	}
	t.load()!
	t.scan()!
	return t
}

// loads tmux session, populate the object
pub fn (mut tmux Tmux) load() ! {
	isrunning := tmux.is_running()!
	if !isrunning {
		tmux.start()!
	}
	// console.print_debug("SCAN")
	tmux.scan()!
}

pub fn (mut t Tmux) stop() ! {
	$if debug {
		console.print_debug('Stopping tmux...')
	}

	t.sessions = []&Session{}
	t.scan()!

	for _, mut session in t.sessions {
		session.stop()!
	}

	cmd := 'tmux kill-server'
	_ := osal.exec(cmd: cmd, stdout: false, name: 'tmux_kill_server', ignore_error: true) or {
		panic('bug')
	}
	os.log('TMUX - All sessions stopped .')
}

pub fn (mut t Tmux) start() ! {
	cmd := 'tmux new-sess -d -s main'
	_ := osal.exec(cmd: cmd, stdout: false, name: 'tmux_start') or {
		return error("Can't execute ${cmd} \n${err}")
	}
	// scan and add default bash window created with session init
	time.sleep(time.Duration(100 * time.millisecond))
	t.scan()!
}

// print list of tmux sessions
pub fn (mut t Tmux) list_print() {
	// os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			console.print_debug(window)
		}
	}
}

// get all windows as found in all sessions
pub fn (mut t Tmux) windows_get() []&Window {
	mut res := []&Window{}
	// os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			res << window
		}
	}
	return res
}

// checks whether tmux server is running
pub fn (mut t Tmux) is_running() !bool {
	res := osal.exec(cmd: 'tmux info', stdout: false, name: 'tmux_info', raise_error: false) or {
		panic('bug')
	}
	if res.error.contains('no server running') {
		// console.print_debug(" TMUX NOT RUNNING")
		return false
	}
	if res.error.contains('no current client') {
		return true
	}
	if res.exit_code > 0 {
		return error('could not execute tmux info.\n${res}')
	}
	return true
}

pub fn (mut t Tmux) str() string {
	mut out := '# Tmux\n\n'
	for s in t.sessions {
		out += '${*s}\n'
	}
	return out
}
