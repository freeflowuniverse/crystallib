module tmux

import os

[heap]
struct Session {
pub mut:
	tmux    &Tmux              [str: skip] // reference back
	windows map[string]&Window // session has windows
	name    string
}

pub fn (mut t Tmux) session_get(name string) !&Session {
	if name in t.sessions {
		return t.sessions[name]
	}
	return error('could not find session $name')
}

pub fn (mut t Tmux) session_get_create(name string, restart bool) !&Session {
	name_l := name.to_lower()
	if name_l !in t.sessions {
		os.log('TMUX - Session $name will be created')
		init_session(mut t, name_l)!
		t.scan()!
	}
	mut session := t.sessions[name_l]
	if restart {
		os.log('TMUX - Session $name will be restarted.')
		session.restart()!
	}
	return session
}

fn init_session(mut tmux Tmux, s_name string) !Session {
	mut s := Session{
		tmux: tmux // reference back
		windows: map[string]&Window{}
		name: s_name.to_lower()
	}
	os.log('SESSION - Initialize session: $s.name')
	s.create()!
	tmux.sessions[s_name] = &s
	return s
}

<<<<<<< HEAD
pub fn (mut s Session) create() ! {
	mut node := s.tmux.node
	res_opt := "-P -F '#{window_id}'"
	cmd := "tmux new-session $res_opt -d -s $s.name 'sh'"
	window_id_ := node.exec(cmd) or {
		return error("Can't create tmux session $s.name \n$cmd\n$err")
	}
=======
pub fn (mut s Session) create() ? {
	mut e := s.tmux.node.executor
	res_opt := "-P -F '#\{window_id\}'"
	cmd := "tmux new-session $res_opt -d -s $s.name 'sh'"
	window_id_ := s.tmux.node.exec(cmd) or { return error("Can't create tmux session $s.name \n$cmd\n$err") }
>>>>>>> ebb33075538a32a1773f9900c05591c4f6be37c8

	cmd3 := 'tmux set-option remain-on-exit on'
	node.exec(cmd3) or { return error("Can't execute $cmd3\n$err") }

	window_id := window_id_.trim(' \n')
	cmd2 := "tmux rename-window -t $window_id 'notused'"
	node.exec(cmd2) or { return error("Can't rename window $window_id to notused \n$cmd2\n$err") }
}

pub fn (mut s Session) restart() ! {
	s.stop()!
	s.create()!
}

pub fn (mut s Session) stop() ! {
	mut node := s.tmux.node
	node.exec('tmux kill-session -t $s.name') or {
		// return error("Can't delete session $s.name - This happen when it is not found")
		''
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
			return error('cannot kill window it already exists, window $namel in session:$s.name')
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
		return error('Cannot find window $name in session:$s.name')
	}
	return s.windows[name_l]
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
