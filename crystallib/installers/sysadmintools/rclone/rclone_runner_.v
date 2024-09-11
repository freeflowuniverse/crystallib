module rclone

import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.ui.console
import time

@[params]
pub struct InstallPlayArgs {
pub mut:
	name       string = 'default'
	heroscript string // if filled in then plbook will be made out of it
	plbook     ?playbook.PlayBook
	reset      bool
	start      bool
	stop       bool
	restart    bool
	delete     bool
	configure  bool // make sure there is at least one installed
}

pub fn play(args_ InstallPlayArgs) ! {
	mut args := args_

	if args.heroscript == '' {
		args.heroscript = heroscript_default
	}
	mut plbook := args.plbook or { playbook.new(text: args.heroscript)! }

	mut install_actions := plbook.find(filter: 'rclone.configure')!
	if install_actions.len > 0 {
		for install_action in install_actions {
			mut p := install_action.params
			cfg_play(p)!
		}
	}
}

@[params]
pub struct RestartArgs {
pub mut:
	reset bool
}

pub fn (mut self RClone) install(args RestartArgs) ! {
	switch(self.name)
	if args.reset || (!installed()!) {
		install()!
	}
}

pub fn (mut self RClone) destroy() ! {
	switch(self.name)

	destroy()!
}
