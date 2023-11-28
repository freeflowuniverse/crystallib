module main

import os
import cli { Command }
import freeflowuniverse.crystallib.core.herocmds

fn do() ! {
	mut cmd := Command{
		name: 'hero'
		description: 'Your HERO for our Crystallib Tools.'
		version: '1.0.0'
		disable_man: true
	}

	// herocmds.cmd_biztools(mut cmd)
	herocmds.cmd_git_get(mut cmd)
	herocmds.cmd_git_do(mut cmd)
	// herocmds.cmd_3script_do(mut cmd)
	herocmds.cmd_imagedownsize(mut cmd)

	cmd.setup()
	cmd.parse(os.args)
}

fn main() {
	do() or { panic(err) }
}
