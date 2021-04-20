module tmux

import os
import vredis2

struct Session {
pub mut:
	tmux    Tmux
	windows map[string]Window
	name    string
}

fn init_session(tmux &Tmux, s_name string) Session {
	mut s := Session{
		tmux: tmux
		windows: map[string]Window{}
		name: s_name.to_lower()
	}
	os.log('SESSION - Initialize session: $s.name')
	s.create()
	return s
}

fn (mut s Session) create() {
	s.tmux.node.executor.exec("tmux new-session -d -s $s.name 'sh'") or {
		panic("Can't create tmux session $s.name")
	}
	s.tmux.node.executor.exec("tmux rename-window -t 0 'notused'") or {
		"Can't rename window 0 to notused"
	}
}

fn (mut s Session) restart() {
	s.stop()
	s.create()
}

fn (mut s Session) stop() {
	s.tmux.node.executor.exec('tmux kill-session -t $s.name') or {
		("Can't delete session $s.name - This happen when it is not found")
	}
}

pub fn (mut s Session) activate() {
	mut redis := vredis2.connect('localhost:6379') or { panic("Couldn't connect to redis client") }
	redis.selectdb(10) or { panic("Couldn't select database'") }
	active_session := redis.get('tmux:active_session') or { 'No active session found' }
	if active_session != 'No active session found' && s.name != active_session {
		s.tmux.node.executor.exec('tmux attach-session -t $active_session') or {
			panic('Fail to attach to current active session: $active_session')
		}
		s.tmux.node.executor.exec('tmux switch -t $s.name') or {
			panic("Can't switch to session $s.name")
		}
		redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
		os.log('SESSION - Session: $s.name activated ')
	} else if active_session == 'No active session found' {
		redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
		os.log('SESSION - Session: $s.name activated ')
	} else {
		os.log('SESSION - Session: $s.name already activate ')
	}
}

fn (mut s Session) execute(cmd string, check string) {
	os.log(cmd)
	os.log(check)
}

fn (mut s Session) window_exist(name string) bool {
	return name.to_lower() in s.windows
}

pub fn (mut s Session) window_get(name string) Window {
	name_l := name.to_lower()
	mut window := Window{}
	if name_l in s.windows {
		os.log('SESSION - Window $name found in previous windows')
		window = s.windows[name_l]
	} else {
		os.log('SESSION - Window $name will be created')
		window = init_window(s, name_l, 0, false, 0)
		s.windows[name_l] = window
	}
	return window
}
