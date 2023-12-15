module main

import os
import cli { Command }
import freeflowuniverse.crystallib.core.herocmds


fn do() ! {
	mut cmd := Command{
		name: 'hero'
		description: 'Your HERO toolset.'
		version: '1.0.0'
		disable_man: true
	}

	// herocmds.cmd_biztools(mut cmd)
	// herocmds.cmd_3script_do(mut cmd)
	herocmds.cmd_git(mut cmd)
	herocmds.cmd_init(mut cmd)
	herocmds.cmd_imagedownsize(mut cmd)
	herocmds.cmd_gen(mut cmd)
	herocmds.cmd_sshagent(mut cmd)
	herocmds.cmd_installers(mut cmd)
	herocmds.cmd_zola(mut cmd)

	cmd.setup()
	cmd.parse(os.args)

	
}

fn main() {
	do() or { panic(err) }
}
