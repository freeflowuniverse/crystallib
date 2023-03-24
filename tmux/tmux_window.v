module tmux

import os

[heap]
struct Window {
pub mut:
	session &Session          [skip]
	name    string
	id      int
	active  bool
	pid     int
	paneid  int
	cmd     string
	env     map[string]string
}

pub struct WindowArgs {
pub mut:
	name  string
	cmd   string
	env   map[string]string
	reset bool
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
pub fn (mut t Tmux) window_new(args WindowArgs) !Window {
	mut s := t.session_get_create('main', false)!
	mut w := s.window_new(args)!
	return w
}

pub fn (mut w Window) create() ! {
	mut node := w.session.tmux.node
	// tmux new-window -P -c /tmp -e good=1 -e bad=0 -n koekoe -t main bash
	if w.active == false {
		res_opt := "-P -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_id}|#{pane_pid}|#{pane_start_command}'"
		cmd := 'tmux new-window  ${res_opt} -t ${w.session.name} -n ${w.name} ${w.cmd}'
		// println(cmd)
		res := node.exec(cmd) or {
			return error("Can't create new window ${w.name} \n${cmd}\n${err}")
		}
		w.session.tmux.scan_add(res)!
		// os.log('WINDOW - Window: $w.name created in session: $w.session.name')
	} else {
		return error('cannot create window, it already exists.\n${w.name}:${w.id}:${w.cmd}')
	}
}

// do some good checks if the window is still active
// not implemented yet
pub fn (mut w Window) check() ! {
	panic('not implemented yet')
}

// restart the window
pub fn (mut w Window) restart() ! {
	w.stop()!
	w.create()!
}

// stop the window
pub fn (mut w Window) stop() ! {
	mut node := w.session.tmux.node
	node.exec_silent('tmux kill-window -t @${w.id}') or {
		return error("Can't kill window with id:${w.id}")
	}
	w.pid = 0
	w.active = false
}

// delete the window
pub fn (mut w Window) delete() ! {
	w.stop()!
	w.session.windows.delete(w.name)
}

pub fn (window Window) str() string {
	return ' - ${window.session.name}:${window.name} wid:${window.id} active:${window.active} pid:${window.pid} cmd:${window.cmd}'
}

// will select the current window so with tmux a we can go there
// if more than 1 session do `tmux a -s mysessionname`
fn (mut w Window) activate() ! {
	mut node := w.session.tmux.node
	cmd2 := 'tmux select-window -t %${w.id}'
	node.exec_silent(cmd2) or { return error("Couldn't select window ${w.name} \n${cmd2}\n${err}") }
}

// show the environment
pub fn (mut w Window) environment_print() ! {
	mut node := w.session.tmux.node
	res := node.exec_silent('tmux show-environment -t %${w.paneid}') or {
		return error('Couldnt show enviroment cmd: ${w.cmd} \n${err}')
	}
	os.log(res)
}

// capture the output
pub fn (mut w Window) output_print() ! {
	mut node := w.session.tmux.node
	//-S is start, minus means go in history, otherwise its only the active output
	res := node.exec_silent('tmux capture-pane -t %${w.paneid} -S -10000') or {
		return error('Couldnt show enviroment cmd: ${w.cmd} \n${err}')
	}
	os.log(res)
}

// tmux capture-pane -t %5 -p -S -10000

// tmux show-environment -t %5
