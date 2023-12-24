module mail

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct Config {
pub mut:
	instance    string
	mail_from   string
	smtp_addr   string
	smtp_login  string
	smpt_port   int = 465
	smtp_passwd string
	ssl         bool
	starttls    bool = true
}

// return a config object even if from partial info
pub fn config(args Config) Config {
	return args
}

// get the configurator
pub fn configurator(instance string, playargs play.PlayArgs) !play.Configurator[Config] {
	mut c := play.configurator_new[Config](
		name: 'mailclient'
		instance: instance
		playargs: playargs
	)!
	return c
}

pub fn play_session(mut session play.Session) ! {
	for mut action in session.plbook.find(filter: 'mailclient.define')! {
		mut p := action.params
		mut args := config()
		args.instance = p.get_default('name', '')!
		if args.instance == '' {
			args.instance = p.get_default('instance', 'default')!
		}
		args.mail_from = p.get('mail_from')!
		args.smtp_addr = p.get('smtp_addr')!
		args.smtp_login = p.get('smtp_login')!
		args.smtp_passwd = p.get('smtp_passwd')!
		args.smpt_port = p.get_int('smpt_port')!
		mut c := configurator(args.instance, session: session)!
		c.set(args)!
	}
}

pub fn configure_interactive(mut args Config, mut session play.Session) ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure Mail Client')
	println('========================\n\n')

	args.instance = myui.ask_question(
		question: 'name for mail client'
		default: args.instance
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
	mut c := configurator(args.instance, session: session)!
	c.set(args)!
}
