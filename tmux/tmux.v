module tmux

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.session
import os
// import redisclient

[heap]
pub struct Tmux {
pub mut:
	sessions map[string]&Session
	sessionid string //unique link to job
}

[params]
pub struct TmuxNewArgs{
	sessionid string
}

//return tmux instance
pub fn new(args TmuxNewArgs) !Tmux {
	return Tmux{sessionid:args.sessionid}
}

// loads tmux session, populate the object
pub fn (mut tmux Tmux) load() ! {
	if !tmux.is_running() {
		return error("Tmux not runnning.")
	}
	tmux_ls := osal.execute_silent('tmux ls')!
	$if debug{println('Tmux: ${tmux_ls}')}
}

pub fn (mut t Tmux) stop() ! {
	$if debug {
		eprintln('Stopping tmux...')
	}

	t.sessions = map[string]&Session{}
	t.scan()!

	for _, mut session in t.sessions {
		session.stop()!
	}

	cmd := 'tmux kill-server'
	_ := osal.execute_silent(cmd) or { '' }
	os.log('TMUX - All sessions stopped .')
}

pub fn (mut t Tmux) start() ! {
	cmd := 'tmux new-sess -d -s init'
	_ := osal.execute_silent(cmd) or {
		return error("Can't execute $cmd \n$err")
	}
	// scan and add default bash window created with session init
	t.scan()!
}

// print list of tmux sessions
pub fn (mut t Tmux) list_print() {
	// os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			println(window)
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
pub fn (mut t Tmux) is_running() bool {
	res := osal.execute_silent('tmux info') or { err.msg() }
	return !res.contains('no server running on /tmp/tmux-0/default')
}
