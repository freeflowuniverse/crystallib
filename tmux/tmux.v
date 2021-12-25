module tmux

import os
import redisclient
import builder

[heap]
struct Tmux {
pub mut:
	sessions map[string]Session
	node     builder.Node [skip]
	redis 	 &redisclient.Redis	[skip]
}

//tmux starts from a node and as such NodeArguments are needed
//
// format ipaddr: localhost:7777
// format ipaddr: 192.168.6.6:7777
// format ipaddr: 192.168.6.6
// format ipaddr: any ipv6 addr
// if only name used then is localhost
//```
// pub struct NodeArguments {
// 	ipaddr string
// 	name   string
// 	user   string = "root"
// 	debug  bool
// 	reset bool
// 	}
//```
//
// will return a tmux object
//
// a redis server is needed, will use DB 10
pub fn new(args builder.NodeArguments) ?Tmux {
	mut redis := redisclient.get_local()?
	redis.selectdb(10)? //select redis DB 10
	mut t := Tmux{
		sessions: map[string]Session{}
		node: builder.node_get(args)?
		redis: redis
	}
	if !t.node.cmd_exists("tmux"){
		os.log("TMUX - could not find tmux command, will try to install, can take a while.")
		t.node.package_install(name:"tmux")?
	}
	t.scan()?
	return t
}

pub fn (mut t Tmux) session_get(name string, restart bool) ?Session {
	name_l := name.to_lower()
	mut session := Session{tmux:&t}
	if name_l in t.sessions {
		os.log('TMUX - Session $name found in previous sessions')
		session = t.sessions[name_l]
	} else {
		os.log('TMUX - Session $name will be created')
		session = init_session(t, name_l)?
		t.sessions[name_l] = &session
	}
	if restart {
		session.restart()?
	}
	return session
}

pub fn (mut t Tmux) execute(session_name string, cmd string, check string, reset bool)? {
		mut s := t.session_get(session_name, reset)?
		s.execute(session_name,cmd,check,reset)?
}

pub fn (mut t Tmux) scan()? {
	os.log('TMUX - Scanning ....')
	exec_list := t.node.executor.exec('tmux list-sessions') or { '1' }

	if exec_list == '1' {
		// No server running
		println('Server not running')
		return
	}

	mut done := map[string]bool{}
	cmd := "tmux list-windows -a -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_pid}|#{pane_start_command}'"
	out := t.node.executor.exec(cmd) or {
		return error("Can't execute $cmd \n$err")
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
			mut session := t.session_get(session_name, false)?

			if key in done {
				return error('Duplicated window name: $key')
			}
			mut active := false
			if pane_active == '1' {
				active = true
			}

			window_name_l := window_name.to_lower()
			if window_name != 'notused' {
				mut window := session.window_get(window_name_l)?
				window.id = (window_id.replace('@', '')).int()
				window.pid = pane_pid.int()
				window.active = active
				done[key] = true
				session.windows[window_name_l] = window
			}
			t.sessions[session_name] = &session
		}
	}
}

pub fn (mut t Tmux) stop()? {
	os.log('TMUX - Stop tmux')
	for _, mut session in t.sessions {
		session.stop()?
	}	
	t.redis.del('tmux:active_session') or { 1 }
	t.redis.del('tmux:active_window') or { 1 }
	os.log('TMUX - All sessions stopped and delete related database entries')
}

//print list of tmux sessions
pub fn (mut t Tmux) list_print() {
	os.log('TMUX - Start listing  ....')
	for _, session in t.sessions {
		for _, window in session.windows {
			println('- $session.name: $window.name')
		}
	}
}
