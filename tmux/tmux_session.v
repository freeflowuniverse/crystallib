module tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.texttools
import os

[heap]
struct Session {
pub mut:
	tmux    &Tmux              [str: skip] // reference back
	windows []&Window // session has windows
	name    string
}

//get session (session has windows) .
//returns none if not found
pub fn (mut t Tmux) session_get(name_ string) ?&Session {
	name:=texttools.name_fix(name_)
	for session in t.sessions {
		if session.name == name {
			return session
		}
	}
	return none
}

[params]
pub struct SessionCreateArgs{
pub mut:
	name string [required]
	reset bool
}


// create session, if reset will re-create
pub fn (mut t Tmux) session_create(args SessionCreateArgs) !&Session {
	name:=texttools.name_fix(name_)
	mut session := t.session_get(name)
	if !session{
		os.log('TMUX - Session ${name} will be created')
		session = Session{
			tmux: t // reference back
			name: name
		}
	}
		init_session(mut t, name_l)!
		t.scan()!
	}
	mut session := t.sessions[name_l] or {panic("cannot find map entry")}
	if restart {
		os.log('TMUX - Session ${name} will be restarted.')
		session.restart()!
	}
	return session
}

fn init_session(mut tmux Tmux, name_ string) !Session {
	name:=texttools.name_fix(name_)
	os.log('SESSION - Initialize session: ${s.name}')
	s.create()!
	tmux.sessions[s_name] = &s
	return s
}

pub fn (mut s Session) create() ! {
	res_opt := "-P -F '#\{window_id\}'"
	cmd := "tmux new-session ${res_opt} -d -s ${s.name} 'sh'"
	window_id_ := osal.execute_silent(cmd) or {
		return error("Can't create tmux session ${s.name} \n${cmd}\n${err}")
	}

	cmd3 := 'tmux set-option remain-on-exit on'
	osal.execute_silent(cmd3) or { return error("Can't execute ${cmd3}\n${err}") }

	window_id := window_id_.trim(' \n')
	cmd2 := "tmux rename-window -t ${window_id} 'notused'"
	osal.execute_silent(cmd2) or {
		return error("Can't rename window ${window_id} to notused \n${cmd2}\n${err}")
	}
}

pub fn (mut s Session) restart() ! {
	s.stop()!
	s.create()!
}

pub fn (mut s Session) stop() ! {
	
	osal.execute_silent('tmux kill-session -t ${s.name}') or {
		return error("Can't delete session ${s.name} - This may happen when session is not found: ${err}")
	}
}

// window_name is the name of the window in session main (will always be called session main)
// cmd to execute e.g. bash file
// environment arguments to use
// reset, if reset it will create window even if it does already exist, will destroy it
// ```
// struct WindowArgs {
// pub mut:
// 	name    string
// 	cmd		string
// 	env		map[string]string	
// 	reset	bool
// }
// ```
pub fn (mut s Session) window_new(args WindowArgs) !Window {
	// os.log(cmd)
	// os.log(check)
	namel := args.name.to_lower()

	if s.window_exist(namel) {
		if args.reset {
			mut w_to_stop := s.window_get(namel)!
			w_to_stop.stop()!
		} else {
			return error('cannot kill window it already exists, window ${namel} in session:${s.name}')
		}
	}
	mut w := Window{
		session: &s
		name: namel
		cmd: args.cmd
		env: args.env
	}
	s.windows[namel] = &w
	w.create()!
	// delete the notused one if there is at least one new one
	// if namel != "notused" && "notused" in s.windows.keys(){
	// 	// os.log(" DELETE notused")
	// 	s.windows["notused"].delete()!
	// }
	return w
}

fn (mut s Session) window_exist(name string) bool {
	return name.to_lower() in s.windows
}

pub fn (mut s Session) window_get(name string) !&Window {
	name_l := name.to_lower()
	if name_l !in s.windows {
		return error('Cannot find window ${name} in session:${s.name}')
	}
	return s.windows[name_l] or {panic("cannot find map entry")}
}

// pub fn (mut s Session) activate()! {	
// 	active_session := s.tmux.redis.get('tmux:active_session') or { 'No active session found' }
// 	if active_session != 'No active session found' && s.name != active_session {
// 		s.tmuxexecutor.db.exec('tmux attach-session -t $active_session') or {
// 			return error('Fail to attach to current active session: $active_session \n$err')
// 		}
// 		s.tmuxexecutor.db.exec('tmux switch -t $s.name') or {
// 			return error("Can't switch to session $s.name \n$err")
// 		}
// 		s.tmux.redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
// 		os.log('SESSION - Session: $s.name activated ')
// 	} else if active_session == 'No active session found' {
// 		s.tmux.redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
// 		os.log('SESSION - Session: $s.name activated ')
// 	} else {
// 		os.log('SESSION - Session: $s.name already activate ')
// 	}
// }
