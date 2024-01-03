module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.base
import cli { Command, Flag }

pub fn cmd_bootstrap(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'bootstrap'
		description: 'bootstrap hero'
		required_args: 0
		execute: cmd_bootstrap_execute
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

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'hero'
		description: 'will compile hero.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'crystal'
		abbrev: 'cr'
		description: 'install crystal lib + vlang.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		name: 'address'
		abbrev: 'a'
		description: 'address in form root@212.3.4.5:2222 or root@212.3.4.5 or root@info.three.com'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_bootstrap_execute(cmd Command) ! {
	mut develop := cmd.flags.get_bool('develop') or { false }
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut hero := cmd.flags.get_bool('hero') or { false }
	mut crystal := cmd.flags.get_bool('crystal') or { false }
	mut address := cmd.flags.get_string('address') or { '' }
	if address==""{
		address="localhost"
	}

	mut b := builder.new()!
	mut n := b.node_new(ipaddr: address)!

	

	if crystal {
		n.crystal_install()!
	} else {
		return error(cmd.help_message())
	}
}
