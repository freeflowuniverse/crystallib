module herocmds

import freeflowuniverse.crystallib.core.generator.installer

import cli { Command, Flag }
import os

pub fn cmd_gen(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'generate'
		description: 'Generate code, ...'
		// required_args: 1
		usage: 'sub commands of generate are installer (only one for now)'
		execute: cmd_gen_execute
		sort_commands: true
	}

	mut gen_command := Command{
		sort_flags: true
		name: 'installer'
		execute: cmd_gen_execute
		description: 'will generate code for installers, execute in the directory where to generate.'
	}

	mut allcmdsref_gen := [&gen_command]

	for mut c in allcmdsref_gen {
		c.add_flag(Flag{
			flag: .bool
			required: true
			name: 'reset'
			abbrev: 'r'
			description: 'do you want to reset all? Dangerous!'
		})
	}
	cmdroot.add_command(cmd_run)
}

fn cmd_gen_execute(cmd Command) ! {

	mut reset := cmd.flags.get_bool('reset') or {false }

	if cmd.name=="installer" {
		installer.generate(reset:reset)!
		return
	} else {
		// println(" Supported commands are: ${gentools.gencmds}")
		return error('Specify sub command: installer')
	}
}
