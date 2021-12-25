module tmux

import os

[heap]
struct Session {
pub mut:
	tmux    &Tmux [skip]		//reference back
	windows map[string]Window	//session has windows
	name    string

}

fn init_session(tmux &Tmux, s_name string) ?Session {
	mut s := Session{
		tmux: tmux						//reference back
		windows: map[string]Window{}
		name: s_name.to_lower()
	}
	os.log('SESSION - Initialize session: $s.name')
	s.create()?
	return s
}

fn (mut s Session) create()? {
	s.tmux.node.executor.exec("tmux new-session -d -s $s.name 'sh'") or {
		return error("Can't create tmux session $s.name \n$err")
	}
	s.tmux.node.executor.exec("tmux rename-window -t 0 'notused'") or {
		return error("Can't rename window 0 to notused \n$err")
	}
}

fn (mut s Session) restart()? {
	s.stop()?
	s.create()?
}

fn (mut s Session) stop()? {
	s.tmux.node.executor.exec('tmux kill-session -t $s.name') or {
		return error("Can't delete session $s.name - This happen when it is not found")
	}
}

pub fn (mut s Session) activate()? {	
	active_session := s.tmux.redis.get('tmux:active_session') or { 'No active session found' }
	if active_session != 'No active session found' && s.name != active_session {
		s.tmux.node.executor.exec('tmux attach-session -t $active_session') or {
			return error('Fail to attach to current active session: $active_session \n$err')
		}
		s.tmux.node.executor.exec('tmux switch -t $s.name') or {
			return error("Can't switch to session $s.name \n$err")
		}
		s.tmux.redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
		os.log('SESSION - Session: $s.name activated ')
	} else if active_session == 'No active session found' {
		s.tmux.redis.set('tmux:active_session', s.name) or { panic('Failed to set tmux:active_session') }
		os.log('SESSION - Session: $s.name activated ')
	} else {
		os.log('SESSION - Session: $s.name already activate ')
	}
}

fn (mut s Session) execute(name string, cmd string, check string, reset bool) ?{
	// os.log(cmd)
	// os.log(check)
	mut w := s.window_get(name)?
	w.execute(cmd, check , reset ) ?
}

fn (mut s Session) window_exist(name string) bool {
	return name.to_lower() in s.windows
}

pub fn (mut s Session) window_get(name string) ?Window {
	name_l := name.to_lower()
	if name_l in s.windows {
		os.log('SESSION - Window $name found in previous windows')
	} else {
		os.log('SESSION - Window $name will be created')
		s.windows[name_l] = init_window(s, name_l, 0, false, 0)?
	}
	return s.windows[name_l]
}
