module tmux

import os
import vredis2

struct Window {
pub mut:
	session Session
	name    string
	id      int
	active  bool
	pid     int
}

fn init_window(session &Session, w_name string, id int, active bool, pid int) Window {
	mut w := Window{
		session: session
		name: w_name.to_lower()
		id: id
		active: active
		pid: pid
	}
	w.create()
	return w
}

fn (mut w Window) create() {
	w.session.activate()
	if w.active == false {
		w.session.tmux.node.executor.exec('tmux new-window -t $w.session.name -n $w.name') or {
			panic("Can't create new window $w.name")
		}

		get_pid := w.session.tmux.node.executor.exec("tmux list-windows -a -F '#{session_name}|#{window_name}|#{pane_pid}' | grep $w.session.name | grep $w.name") or {"Test"}
		get_pid_arr := get_pid.split('|')
		w.pid = get_pid_arr[2].int()
		os.log('WINDOW - Window: $w.name created in session: $w.session.name')
	}
}

fn (mut w Window) restart() {
	w.stop()
	w.create()
}

pub fn (mut w Window) stop() {
	if w.pid > 0 {
		w.session.tmux.node.executor.exec('kill -9 $w.pid') or {
			panic("Can't kill window with pid:$w.pid")
		}
	}
	w.pid = 0
	w.active = false
	w.session.windows.delete(w.name)
}

fn (mut w Window) activate() {
	mut redis := vredis2.connect('localhost:6379') or { panic("Couldn't connect to redis client") }
	redis.selectdb(10) or { panic("Couldn't select database'") }
	key := '$w.session.name:$w.name'
	active_window := redis.get('tmux:active_window') or { 'No active window found' }
	if active_window != key || !w.active || w.pid == 0 {
		if !w.active || w.pid == 0 {
			w.restart()
			w.active = true
		}else{
			w.session.activate()
		}
		w.session.tmux.node.executor.exec('tmux select-window -t $w.id') or {
			panic("Couldn't select window $w.name'")
		}
		redis.set('tmux:active_window', key) or { panic("Couldn't set tmux:active_window") }
		os.log('WINDOW - Window: $w.name activated ')
	} else {
		os.log('WINDOW - Window $w.name already active')
	}
}

pub fn (mut w Window) execute(cmd string, check string, reset bool) {
	w.activate()
	if reset {
		w.restart()
	}
	w.session.tmux.node.executor.exec("tmux send-keys -t $w.session.name'.'$w.id '$cmd' Enter") or {
		panic("Couldn't execute cmd: $cmd")
	}
	os.log('WINDOW - Window: $w.name execute: $cmd')
	if check != '' {
		error('implement')
		w.session.tmux.node.executor.exec('tmux') or { panic(err) }
	}
}
