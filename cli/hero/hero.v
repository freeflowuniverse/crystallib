module main

import os
import cli { Command }
import freeflowuniverse.crystallib.core.herocmds
import freeflowuniverse.crystallib.core.play


fn do() ! {
	mut cmd := Command{
		name: 'hero'
		description: 'Your HERO toolset.'
		version: '1.0.0'
		disable_man: true
	}

	play.init_default()!

	herocmds.cmd_bootstrap(mut cmd)
	herocmds.cmd_run(mut cmd)
	herocmds.cmd_git(mut cmd)
	herocmds.cmd_init(mut cmd)
	herocmds.cmd_imagedownsize(mut cmd)
	// herocmds.cmd_biztools(mut cmd)
	// herocmds.cmd_gen(mut cmd)
	// herocmds.cmd_sshagent(mut cmd)
	herocmds.cmd_installers(mut cmd)
	// herocmds.cmd_zola(mut cmd)
	// herocmds.cmd_configure(mut cmd)
	// herocmds.cmd_postgres(mut cmd)
	herocmds.cmd_mdbook(mut cmd)
	


	cmd.setup()
	cmd.parse(os.args)

	
}

fn main() {
	do() or { panic(err) }
}
