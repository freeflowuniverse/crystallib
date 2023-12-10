module herocmds

import freeflowuniverse.crystallib.osal.sshagent
import freeflowuniverse.crystallib.ui.console
import cli { Command, Flag }
import os

pub fn cmd_sshagent(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'sshagent'
		description: 'Work with SSHAgent'
		// required_args: 1
		usage: 'sub commands of generate are list, generate, unload, load'
		execute: cmd_sshagent_execute
		sort_commands: true
	}

	mut sshagent_command_list := Command{
		sort_flags: true
		name: 'list'
		execute: cmd_sshagent_execute
		description: 'list ssh-keys.'
	}

	mut sshagent_command_generate := Command{
		sort_flags: true
		name: 'generate'
		execute: cmd_sshagent_execute
		description: 'generate ssh-key.'
	}

	mut sshagent_command_load := Command{
		sort_flags: true
		name: 'load'
		execute: cmd_sshagent_execute
		description: 'load ssh-key in agent.'
	}

	mut sshagent_command_unload := Command{
		sort_flags: true
		name: 'unload'
		execute: cmd_sshagent_execute
		description: 'Unload ssh-key from agent.'
	}

	mut allcmdsref_gen := [&sshagent_command_list,&sshagent_command_generate,&sshagent_command_load,&sshagent_command_unload ]

	for mut c in allcmdsref_gen {
		// c.add_flag(Flag{
		// 	flag: .bool
		// 	name: 'reset'
		// 	abbrev: 'r'
		// 	description: 'do you want to reset all? Dangerous!'
		// })
		c.add_flag(Flag{
			flag: .bool
			name: 'script'
			abbrev: 's'
			description: 'runs non interactive!'
		})

		cmd_run.add_command(*c)
	}
	cmdroot.add_command(cmd_run)
}

fn cmd_sshagent_execute(cmd Command) ! {

	// mut reset := cmd.flags.get_bool('reset') or {false }
	mut isscript := cmd.flags.get_bool('script') or {false }

	mut agent:=sshagent.new()!

	if cmd.name=="list" {
		if !isscript{
			console.clear()
		}		
		println(agent)
		return
	} else {
		
		// println(1)
		return error(cmd.help_message())
		// println(" Supported commands are: ${gentools.gencmds}")
		// return error('unknown subcmd')
	}
}
