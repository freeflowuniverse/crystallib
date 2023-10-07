module main

import os
import cli { Command,Flag }
import mycmds


fn do() ! {

	mut cmd := Command{
		name: 'bizmodel'
		description: 'Bizmodel Executor.'
		version: '1.0.0'
		disable_man:true
	}

	mycmds.cmd_run_config(mut cmd)
	mycmds.cmd_git_config(mut cmd)
	mycmds.cmd_git_actions(mut cmd)
	

    cmd.setup()
    cmd.parse(os.args)



}


fn main() {
	do() or { panic(err) }
}
