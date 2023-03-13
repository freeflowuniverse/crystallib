module tmux

import freeflowuniverse.crystallib.builder
import os
// import redisclient

[heap]
pub struct Tmux {
pub mut:
	sessions map[string]&Session
	node     builder.Node
}

pub fn get_local() !Tmux {
	mut builder_ := builder.new()
	mut node := builder_.node_local()!
	return Tmux{
		node: node
	}
}

pub fn get_remote(ipaddr string) !Tmux {
	mut builder_ := builder.new()
	mut node := builder_.node_new(name: 'test', ipaddr: ipaddr, debug: true)!
	return Tmux{
		node: node
	}
}

fn (mut t Tmux) scan_add(line string) !&Window {
	// println(" -- scan add")
	if line.count('|') < 4 {
		return error(@FN + 'expects line with at least 5 params separated by |')
	}
	line_arr := line.split('|')
	session_name := line_arr[0]
	window_name := line_arr[1]
	window_id := line_arr[2]
	pane_active := line_arr[3]
	pane_id := line_arr[4]
	pane_pid := line_arr[5]
	pane_start_command := line_arr[6] or { '' }

	// os.log('TMUX FOUND: $line\n    ++ $session_name:$window_name wid:$window_id pid:$pane_pid entrypoint:$pane_start_command')
	mut session := t.session_get(session_name)!

	// if key in done {
	// 	return error('Duplicated window name: $key')
	// }
	mut active := false
	if pane_active == '1' {
		active = true
	}

	window_name_l := window_name.to_lower()
	if window_name_l !in session.windows {
		mut w1 := Window{
			session: session
		}
		session.windows[window_name_l] = &w1
		// println("NOT IN WINDOWS: $window_name_l")
	}

	mut w := session.windows[window_name_l]

	w.name = window_name_l
	w.id = (window_id.replace('@', '')).int()
	w.active = active
	w.pid = pane_pid.int()
	w.paneid = (pane_id.replace('%', '')).int()
	w.cmd = pane_start_command

	return w
}

// scan and return which ones where in struct but not found in the system
// probably means a command did not start well
pub fn (mut t Tmux) scan() !map[string]&Window {
	// os.log('TMUX - Scanning ....')
	mut node := t.node
	cmd_list_session := "tmux list-sessions -F '#{session_name}'"
	exec_list := node.exec_silent(cmd_list_session)!

	// if exec_list == '1' {
	// 	// No server running
	// 	// TODO: need to do better, is too rough
	// 	// os.log('TMUX: Server not running, cannot find sessions')
	// 	return map[string]&Window{}
	// }

	println('execlist out: ${exec_list}')

	// make sure we have all sessions
	for line in exec_list.split_into_lines() {
		session_name := line.trim(' \n').to_lower()
		if session_name == '' {
			continue
		}
		if session_name in t.sessions {
			continue
		}
		mut s := Session{
			tmux: &t // reference back
			windows: map[string]&Window{}
			name: session_name
		}
		t.sessions[session_name] = &s
	}

	// mut done := map[string]bool{}
	cmd := "tmux list-panes -a -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_id}|#{pane_pid}|#{pane_start_command}'"
	out := node.exec_silent(cmd) or { return error("Can't execute ${cmd} \n${err}") }

	println('node out: ${out}')

	mut windows := t.windows_get()

	println('windows out: ${windows.keys()}')

	for line in out.split_into_lines() {
		if line.contains('|') {
			w := t.scan_add(line)!
			if w.name in windows {
				windows.delete(w.name)
			}
		}
	}

	for _, mut w2 in windows {
		w2.check()!
	}
	return windows
}

// loads tmux session, from running tmux server to struct
pub fn (mut tmux Tmux) load() ! {
	if !tmux.is_running() {
		return
	}
	tmux_ls := tmux.node.exec('tmux ls')!
	println('Tmux: ${tmux_ls}')
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
	_ := t.node.exec_silent(cmd) or { '' }
	os.log('TMUX - All sessions stopped .')
}

pub fn (mut t Tmux) start() ! {
	cmd := 'tmux new-sess -d -s init'
	_ := t.node.exec_silent(cmd) or {
		// return error("Can't execute $cmd \n$err")
		''
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

// get all windows in new map
pub fn (mut t Tmux) windows_get() map[string]&Window {
	mut res := map[string]&Window{}
	// os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			res[window.name] = window
		}
	}
	return res
}

// checks whether tmux server is running
pub fn (mut t Tmux) is_running() bool {
	res := t.node.exec_silent('tmux info') or { err.msg() }
	return !res.contains('no server running on /tmp/tmux-0/default')
}
