module mail

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import net.smtp

pub struct MailClient[T] {
	play.BaseConfig
pub mut:
	config      Config
	smtp_client &smtp.Client
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype  string = 'mailclient' // needs to be defined	
	instance    string
	mail_from   string
	smtp_addr   string
	smtp_login  string
	smtp_port   int = 587
	smtp_passwd string
	ssl         bool
	starttls    bool = true
}

pub fn get(args play.PlayArgs) !MailClient[Config] {
	smtp_client := &smtp.Client{}
	mut client := MailClient[Config]{
		smtp_client: smtp_client
	}
	client.init(args)!
	return client
}

pub fn heroplay(args play.PLayBookAddArgs) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'mailclient.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		cfg.description = p.get_default('description', 'mailclient')!
		cfg.mail_from = p.get('mail_from')!
		cfg.smtp_addr = p.get('smtp_addr')!
		cfg.smtp_login = p.get('smtp_login')!
		cfg.smtp_port = p.get_int('smtp_port')!
		cfg.smtp_passwd = p.get('smtp_passwd')!
		cfg.ssl = p.get_default_false('ssl')
		cfg.starttls = p.get_default_true('startssl')
		cl.config_save()!
	}
}

pub fn (mut self MailClient[Config]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure Mail Client')
	println('========================\n\n')
	mut cfg := self.config()!
	self.instance = myui.ask_question(
		question: 'name for mail client'
	)!

	cfg.smtp_login = myui.ask_question(
		question: 'smtp login'
		minlen: 3
	)!
	cfg.mail_from = myui.ask_question(
		question: 'mail_from e.g. myname@domain.com'
		minlen: 5
	)!

	cfg.smtp_addr = myui.ask_question(
		question: 'smtp addr e.g. smtp-relay.brevo.com'
		minlen: 5
	)!

	cfg.smtp_passwd = myui.ask_question(
		question: 'smtp passwd'
		minlen: 3
	)!
	mut smtp_port := myui.ask_question(
		question: 'smtp port'
	)!
	cfg.smtp_port = smtp_port.int()

	cfg.ssl = myui.ask_yesno(
		question: 'ssl, prob no'
	)!

	cfg.starttls = myui.ask_yesno(
		question: 'starttls, means encrypted'
		default: false
	)!
	self.config_save()!
}
