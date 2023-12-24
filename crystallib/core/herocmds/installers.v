module herocmds

import freeflowuniverse.crystallib.installers.tools
import cli { Command, Flag }

pub fn cmd_installers(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'installers'
		description: 'a set of installers'
		required_args: 0
		execute: cmd_installers_execute
	}

	// mut caddy_cmd := Command{
	// 	sort_flags: true
	// 	name: 'caddy'
	// 	execute: cmd_installers_execute
	// 	description: ''
	// }

	caddy_cmd.add_flag(Flag{
		flag: .string
		required: false
		name: 'names'
		abbrev: 'n'
		description: 'Comma separated list of installers to call.'
	})
	caddy_cmd.add_flag(Flag{
		flag: .bool
		required: false
		name: 'reset'
		abbrev: 'r'
		description: 'will reset.'
	})

	cmdroot.add_command(cmd_run)
	// cmd_run.add_command(caddy_cmd)
}

fn cmd_installers_execute(cmd Command) ! {
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut names := cmd.flags.get_string('names') or { false }

	// if cmd.name == 'caddy' {
	// 	caddy.install(reset: reset)!
	// 	return
	// } else {
	// 	return error(cmd.help_message())
	// }

	tools.install_multi(reset: reset, names: names)!
}
