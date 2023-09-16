module tmux

import freeflowuniverse.crystallib.osal
import os

fn (mut t Tmux) scan_add(line string) !Window {
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

	mut w := session.windows[window_name_l] or {error("cannot find $window_name_l")}

	w.name = window_name_l
	w.id = (window_id.replace('@', '')).int()
	w.active = active
	w.pid = pane_pid.int()
	w.paneid = (pane_id.replace('%', '')).int()
	w.cmd = pane_start_command

	return w
}

// scan the system to detect sessions .
// probably means a command did not start well
pub fn (mut t Tmux) scan() ![]Window {
	// os.log('TMUX - Scanning ....')
	
	cmd_list_session := "tmux list-sessions -F '#{session_name}'"
	exec_list := osal.execute_silent(cmd_list_session)!

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
	out := osal.execute_silent(cmd) or { return error("Can't execute ${cmd} \n${err}") }

	$if debug{println('tmux list panes out:\n${out}')}

	mut windows := t.windows_get()

	$if debug{println('windows: ${windows.keys()}')}

	for line in out.split_into_lines() {
		if line.contains('|') {
			w := t.scan_add(line)!
			if w.name in windows {
				windows.delete(w.name)
			}
		}
	}

	for mut w2 in windows {
		w2.check()!
	}
	return windows
}
