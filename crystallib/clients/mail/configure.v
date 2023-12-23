module mail

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.context
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.playbook
import json
import net.smtp
import time
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct Config {
pub mut:
	instance    string = 'default'
	mail_from   string
	smtp_addr   string
	smtp_login  string
	smpt_port   int = 465
	smtp_passwd string
	ssl         bool
	starttls    bool = true
}

fn configure_key(instance string) string {
	instance2 := texttools.name_fix(instance)
	return 'mail_config_${instance2}'
}

fn configure_db() fskvs.KVS {
	mut context := context.new(encryption: true)!
	mut db := context.get(name: 'test1', encryption: true)!
	return 'mail_config_${name2}'
}

pub fn configure(args_ Config) !Config {
	mut kvs := fskvs.new(name: 'config')!
	key := configure_key(args.name)
	if args.reset || !kvs.exists(key) {
		data := json.encode_pretty(args)
		kvs.set(key, data)!
	}
	data := kvs.get(key)!
	mut client_config := json.decode(Config, data)!
	return client_config
}

pub fn configure_reset() ! {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	key := 'mail_config_${args.name}'
	mut kvs := fskvs.new(name: 'config')!
	if args.reset || !kvs.exists(key) {
		data := json.encode_pretty(args)
		kvs.set(key, data)!
	}
	data := kvs.get(key)!
	mut client_config := json.decode(Config, data)!
	return client_config
}

pub fn configure_3script(script3 string) !Config {
	// means 3script used to configure this client
	mut ap := playbook.parse_playbook(text: args.script3)!
	for action in ap.actions {
		if action.actor == 'mailclient' && action.name == 'define' {
			args.name = action.params.get_default('name', 'default')!
			args.mail_from = action.params.get('mail_from')!
			args.smtp_addr = action.params.get('smtp_addr')!
			args.smtp_login = action.params.get('smtp_login')!
			args.smtp_passwd = action.params.get('smtp_passwd')!
			args.smpt_port = action.params.get_int('smpt_port')!
		}
	}
}

pub fn configure_interactive(args_ Config) ! {
	mut args := configure(args_)!
	mut myui := ui.new()!

	console.clear()
	println('\n## Configure Mail Client')
	println('========================\n\n')

	args.name = myui.ask_question(
		question: 'name for mail client'
		default: args.name
	)!

	args.smtp_login = myui.ask_question(
		question: 'smtp login'
		minlen: 3
		default: args.smtp_login
	)!
	args.mail_from = myui.ask_question(
		question: 'mail_from e.g. myname@domain.com'
		minlen: 5
		default: args.mail_from
	)!

	args.smtp_addr = myui.ask_question(
		question: 'smtp addr e.g. smtp-relay.brevo.com'
		minlen: 5
		default: args.smtp_addr
	)!

	args.smtp_passwd = myui.ask_question(
		question: 'smtp passwd'
		minlen: 3
		default: args.smtp_passwd
	)!
	mut smpt_port := myui.ask_question(
		question: 'smtp port'
		default: '${args.smpt_port}'
	)!
	args.smpt_port = smpt_port.int()

	args.starttls = myui.ask_yesno(
		question: 'starttls, means encrypted'
		default: args.starttls
	)!
	args.ssl = myui.ask_yesno(
		question: 'ssl, prob no'
		default: args.ssl
	)!
	args.reset = true
	println(args)
	configure(args)!
}
