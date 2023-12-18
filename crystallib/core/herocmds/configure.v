module herocmds

import freeflowuniverse.crystallib.clients.mail
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.builder
import cli { Command, Flag }
import os

pub fn cmd_configure(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'configure'
		description: 'configure parameters for hero environment.'
		required_args: 0
		execute: cmd_configure_execute
	}

	mut mail_cmd := Command{
		sort_flags: true
		name: 'mail'
		execute: cmd_configure_execute
		description: ''
	}
	mut allcmdsref := [&mail_cmd]
	for mut c in allcmdsref {
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'name'
			abbrev: 'n'
			description: 'name of the instance to configure.'
		})
		c.add_flag(Flag{
			flag: .bool
			required: false
			name: 'reset'
			abbrev: 'r'
			description: 'will reset.'
		})
		c.add_flag(Flag{
			flag: .bool
			required: false
			name: 'show'
			abbrev: 's'
			description: 'will show the command.'
		})
		c.add_flag(Flag{
			flag: .bool
			required: false
			name: 'test'
			abbrev: 't'
			description: 'do a test.'
		})
		c.add_flag(Flag{
			flag: .string
			required: false
			name: 'push'
			abbrev: 'p'
			description: 'push this config to a destination over ssh e.g. root@212.3.247.26'
		})
	}

	cmd_run.add_command(mail_cmd)
	cmdroot.add_command(cmd_run)
}

fn cmd_configure_execute(cmd Command) ! {
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut show := cmd.flags.get_bool('show') or { false }
	mut test := cmd.flags.get_bool('test') or { false }
	mut name := cmd.flags.get_string('name') or { 'default' }
	mut push := cmd.flags.get_string('push') or { '' }
	if name == '' {
		name = 'default'
	}

	if cmd.name == 'mail' {
		if show {
			cl := mail.configure(name: name)!
			println(cl)
		} else if test {
			mut cl := mail.get(name: name)!
			// println(cl)
			mut myui := ui.new()!
			to := myui.ask_question(
				question: 'send test mail to'
			)!
			cl.send(to: to, subject: 'this is test mail', body: 'this is example mail.')!
		} else if push == '' {
			mail.configure_interactive(reset: reset, name: name)!
		}
	} else {
		return error(cmd.help_message())
	}
	if push.len > 0 {
		println(" - will push config: ${name} to '${push}'")
		path := '${os.home_dir()}/hero/db/config/${cmd.name}_config_${name}'
		path_dest := '~/hero/db/config/${cmd.name}_config_${name}'
		if !os.exists(path) {
			return error('cannot find the source config on: ${path}')
		}
		mut myui := ui.new()!
		ok := myui.ask_yesno(question: 'are you sure?')!
		if ok {
			mut b := builder.new()!
			mut n := b.node_new(ipaddr: push)!
			n.upload(source: path, dest: path_dest, delete: true)!
		}
	}
}
