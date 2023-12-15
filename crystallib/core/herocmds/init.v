
module herocmds

import freeflowuniverse.crystallib.osal
import cli { Command, Flag }

pub fn cmd_init(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'init'
		description: 'init hero'
		required_args: 0
		execute: cmd_init_execute
	}


	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'reset'
		abbrev: 'r'
		description: 'will reset.'
	})

	cmdroot.add_command(cmd_run)
	
}

fn cmd_init_execute(cmd Command) ! {
	mut reset := cmd.flags.get_bool('reset') or { false }
	
	r:=osal.profile_path_add_hero()!
	println(" - add path ${r} to profile.")
	println(" - hero init ok.")

}
