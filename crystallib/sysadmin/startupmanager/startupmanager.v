module startupmanager

// import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.osal.screen
import json
// import os

pub enum StartupManagerType {
	screen
	zinit
	tmux
}

pub struct StartupManager {
pub mut:
	cat StartupManagerType
}

pub struct StartupManagerArgs {
pub mut:
	cat StartupManagerType
}

pub fn configure(args StartupManagerArgs) ! {
	mut r := redisclient.core_get()!
	mut d := json.encode_pretty(args)
	r.set('startupmanager', d)!
}

pub fn get() !StartupManager {
	mut r := redisclient.core_get()!
	exists := r.exists('startupmanager')!
	if !exists {
		configure(cat: .screen)!
	}
	data := r.get('startupmanager')!
	mut args := json.decode(StartupManagerArgs, data)!
	mut sm := StartupManager{
		cat: args.cat
	}
	return sm
}

pub struct StartArgs {
pub mut:
	name  string @[requred]
	cmd   string
	reset bool
	// start  bool = true
	// attach bool
}

// launch a new process
pub fn (mut sm StartupManager) start(args StartArgs) ! {
	match sm.cat {
		.screen {
			mut scr := screen.new(reset: false)!
			_ = scr.add(name: args.name, cmd: args.cmd, reset: args.reset)!
		}
		else {
			panic('to implement, startup manager only support screen for now')
		}
	}
}

// kill the process by name
pub fn (mut sm StartupManager) kill(name string) ! {
	match sm.cat {
		.screen {
			mut scr := screen.new(reset: false)!
			scr.kill(name)!
		}
		else {
			panic('to implement, startup manager only support screen for now')
		}
	}
}
