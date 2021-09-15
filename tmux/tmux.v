module tmux

import os
import vredis2
import crystallib.builder

struct Tmux {
mut:
	sessions map[string]Session
	node     builder.Node
}

pub fn new(args builder.NodeArguments) Tmux {
	mut t := Tmux{
		sessions: map[string]Session{}
		node: builder.node_get(args) or { panic(err) }
	}
	t.scan()
	return t
}

pub fn (mut t Tmux) session_get(name string, restart bool) Session {
	name_l := name.to_lower()
	mut session := Session{}
	if name_l in t.sessions {
		os.log('TMUX - Session $name found in previous sessions')
		session = t.sessions[name_l]
	} else {
		os.log('TMUX - Session $name will be created')
		session = init_session(t, name_l)
		t.sessions[name_l] = session
	}
	if restart {
		session.restart()
	}
	return session
}

pub fn (mut t Tmux) scan() {
	os.log('TMUX - Scanning ....')
	exec_list := t.node.executor.exec('tmux list-sessions') or { '1' }

	if exec_list == '1' {
		// No server running
		println('Server not running')
		return
	}

	mut done := map[string]bool{}

	out := t.node.executor.exec("tmux list-windows -a -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_pid}|#{pane_start_command}'") or {
		panic("Can't execute")
	}
	for line in out.split_into_lines() {
		if line.contains('|') {
			line_arr := line.split('|')
			session_name := line_arr[0]
			window_name := line_arr[1]
			window_id := line_arr[2]
			pane_active := line_arr[3]
			pane_pid := line_arr[4]
			pane_start_command := line_arr[5] or { '' }

			key := session_name + '-' + window_name
			println('--------------------------------------')
			os.log('TMUX - Found session: $session_name')
			println('window:$window_name \nwindow_id: $window_id \nprocess: $pane_pid \nentrypoint:$pane_start_command')
			println('--------------------------------------')
			mut session := t.session_get(session_name, false)

			if key in done {
				error('Duplicated window name: $key')
			}
			mut active := false
			if pane_active == '1' {
				active = true
			}

			window_name_l := window_name.to_lower()
			if window_name != 'notused' {
				mut window := session.window_get(window_name_l)
				window.id = (window_id.replace('@', '')).int()
				window.pid = pane_pid.int()
				window.active = active
				done[key] = true
				session.windows[window_name_l] = window
			}
			t.sessions[session_name] = session
		}
	}
}

pub fn (mut t Tmux) stop() {
	os.log('TMUX - Stop tmux')
	for _, mut session in t.sessions {
		session.stop()
	}
	mut redis := vredis2.connect('localhost:6379') or { panic("Couldn't connect to redis client") }
	redis.selectdb(10) or { panic("Couldn't select database'") }
	redis.del('tmux:active_session') or { 1 }
	redis.del('tmux:active_window') or { 1 }
	os.log('TMUX - All sessions stopped and delete related database entries')
}

pub fn (mut t Tmux) list() {
	os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			println('- $session.name: $window.name')
		}
	}
}
