module builder

import os

[heap]
struct Window {
pub mut:
	session &Session [skip]
	name    string
	id      int
	active  bool
	pid     int
	paneid	int
	cmd		string
	env		map[string]string
}


pub struct WindowArgs {
pub mut:
	name    string
	cmd		string
	env		map[string]string	
	reset	bool
}

pub fn (mut w Window) create()? {
	mut e:= w.session.tmux.node().executor
	//tmux new-window -P -c /tmp -e good=1 -e bad=0 -n koekoe -t main bash
	if w.active == false {
		res_opt := "-P -F '#{session_name}|#{window_name}|#{window_id}|#{pane_active}|#{pane_id}|#{pane_pid}|#{pane_start_command}'"
		cmd := "tmux new-window  $res_opt -t $w.session.name -n $w.name $w.cmd"
		// println(cmd)
		res := e.exec(cmd) or {
			return error("Can't create new window $w.name \n$cmd\n$err")
		}
		w.session.tmux.scan_add(res)?
		// os.log('WINDOW - Window: $w.name created in session: $w.session.name')
	}else{
		return error("cannot create window, it already exists.\n${w.name}:${w.id}:${w.cmd}")
	}
}

pub fn (mut w Window) check()? {
	//do some good checks if the window is still active
}

pub fn (mut w Window) restart()? {
	w.stop()?
	w.create()?
}

pub fn (mut w Window) stop()? {
	mut e:= w.session.tmux.node().executor
	e.exec_silent('tmux kill-window -t @${w.id}') or {
		return error("Can't kill window with id:$w.id")
	}
	w.pid = 0
	w.active = false
}

pub fn (mut w Window) delete()? {
	w.stop()?
	w.session.windows.delete(w.name)
}

pub fn (window Window) repr() string {
	return ' - ${window.session.name}:${window.name} wid:${window.id} active:${window.active} pid:${window.pid} cmd:${window.cmd}'
}

//will select the current window so with tmux a we can go there
// if more than 1 session do `tmux a -s mysessionname`
fn (mut w Window) activate()? {
	mut e:= w.session.tmux.node().executor
	cmd2 := "tmux select-window -t %${w.id}"
		e.exec_silent(cmd2) or {
			return error("Couldn't select window $w.name \n$cmd2\n$err")
		}
}

//show the environment
pub fn (mut w Window) environment_print()? {
	mut e:= w.session.tmux.node().executor
	res := e.exec_silent("tmux show-environment -t %${w.paneid}") or {
		return error("Couldnt show enviroment cmd: $w.cmd \n$err")
	}
	os.log(res)
}

//capture the output
pub fn (mut w Window) output_print()? {
	mut e:= w.session.tmux.node().executor
	//-S is start, minus means go in history, otherwise its only the active output
	res := e.exec_silent("tmux capture-pane -t %${w.paneid} -S -10000") or {
		return error("Couldnt show enviroment cmd: $w.cmd \n$err")
	}
	os.log(res)
}


// tmux capture-pane -t %5 -p -S -10000

// tmux show-environment -t %5