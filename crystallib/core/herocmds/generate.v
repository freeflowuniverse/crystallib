module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.crystallib
import freeflowuniverse.crystallib.core.generator.installer
import freeflowuniverse.crystallib.ui.console
import os

import cli { Command, Flag }

pub fn cmd_generator(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'generate'
		description: 'generator for vlang code in hero context.'
		required_args: 0
		execute: cmd_generator_execute
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
		name: 'path'
		abbrev: 'p'
		description: 'will put system in development mode.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_generator_execute(cmd Command) ! {
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut path := cmd.flags.get_string('path') or { '' }

	if path == ""{
		path = os.getwd()
	}

	path = path.replace("~",os.home_dir())

	console.print_header("Generate code for ${path}")

	installer.scan(path)!

}
