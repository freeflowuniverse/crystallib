
module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
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

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'develop'
		abbrev: 'd'
		description: 'will put system in development mode.'
	})


	cmdroot.add_command(cmd_run)
	
}

fn cmd_init_execute(cmd Command) ! {
	mut develop := cmd.flags.get_bool('develop') or { false }
	mut reset := cmd.flags.get_bool('reset') or { false }

	base.install()!

	if develop{
		base.develop(reset:reset)!
	}
	
	r:=osal.profile_path_add_hero()!
	println(" - add path ${r} to profile.")
	println(" - hero init ok.")

}
