module screen

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import os
import time

@[heap]
struct Screen {
mut:
	cmd   string
	name  string
	pid   int
	state ScreenState
	// factory ?&ScreensFactory @[skip; str: skip]
}

enum ScreenState {
	unknown
	detached
}

// checks whether screen server is running
pub fn (mut t Screen) is_running() !bool {
	panic('implement')
	// res := osal.exec(cmd: 'screen info', stdout: false, name: 'screen_info', raise_error: false) or {
	// 	panic('bug')
	// }
	// if res.error.contains('no server running') {
	// 	// println(" TMUX NOT RUNNING")
	// 	return false
	// }
	// if res.error.contains('no current client') {
	// 	return true
	// }
	// if res.exit_code > 0 {
	// 	return error('could not execute screen info.\n${res}')
	// }
	return true
}

fn (mut self Screen) kill_() ! {
	println('kill screen: ${self}')
	if self.pid == 0 || self.pid < 50 {
		return error("pid was <50 for ${self}, can't kill")
	}
	osal.process_kill_recursive(self.pid)!
	res := os.execute('export TERM=xterm-color && screen -X -S ${self.name} kill')
	if res.exit_code > 1 {
		return error('could not kill a screen.\n${res.output}')
	}
	time.sleep(100000) // 0.1 sec wait
	os.execute('screen -wipe')
	// self.scan()!
}

// fn (mut self Screen) scan() ! {
// 	mut f:=self.factory or {panic("bug, no factory attached to screen.")}
// 	f.scan(false)!
// }

pub fn (mut self Screen) attach() ! {
	cmd := 'screen -r ${self.pid}.${self.name}'
	osal.execute_interactive(cmd)!
}

pub fn (mut self Screen) cmd_send(cmd string) ! {
	cmd2 := "screen -S ${self.name} -p 0 -X stuff \"${cmd}\"\$'\n' "
	// println(cmd2)
	res := os.execute(cmd2)
	if res.exit_code > 1 {
		return error('could not send screen command.\n${cmd2}\n${res.output}')
	}
}

pub fn (mut self Screen) str() string {
	green := console.color_fg(.green)
	yellow := console.color_fg(.yellow)
	reset := console.reset
	return ' - screen:${green}${self.name:-20}${reset} pid:${yellow}${self.pid:-10}${reset} state:${green}${self.state}${reset}'
}

fn (mut self Screen) start_() ! {
	if self.pid != 0 {
		return
	}
	if self.name.len == 0 {
		return error('screen name needs to exist.')
	}
	if self.cmd == '' {
		self.cmd = '/bin/bash'
	}
	cmd := 'export TERM=xterm-color && screen -dmS ${self.name} ${self.cmd}'
	println(" startcmd:'${cmd}'")
	res := os.execute(cmd)
	// println(res)
	if res.exit_code > 1 {
		return error('could not find screen or other error, make sure screen is installed.\n${res.output}')
	}
}
