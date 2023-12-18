module mail

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.data.actionparser
import json
import net.smtp
import time
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct MailClientConfig {
pub mut:
	name        string = 'default'
	mail_from   string
	smtp_addr   string
	smtp_login  string
	smpt_port   int = 465
	smtp_passwd string
	ssl         bool
	starttls    bool = true
	script3     string
	reset       bool
}

pub struct MailClient {
pub mut:
	name        string      @[required]
	smtp_client smtp.Client
}

pub fn get(args_ MailClientConfig) !MailClient {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	args = configure(args)!
	// println(args)
	mut smtp_client := smtp.new_client(
		server: args.smtp_addr
		port: args.smpt_port
		username: args.smtp_login
		password: args.smtp_passwd
		from: args.mail_from
		ssl: args.ssl
		starttls: args.starttls
	)!
	// println(smtp_client)
	return MailClient{
		name: args.name
		smtp_client: smtp_client
	}
}

pub fn configure(args_ MailClientConfig) !MailClientConfig {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	if args.script3.len > 0 {
		// means 3script used to configure this client
		mut ap := actionparser.parse_collection(text: args.script3)!
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

	key := 'mail_config_${args.name}'
	mut kvs := fskvs.new(name: 'config')!
	if args.reset || !kvs.exists(key) {
		data := json.encode_pretty(args)
		kvs.set(key, data)!
	}
	data := kvs.get(key)!
	mut client_config := json.decode(MailClientConfig, data)!
	return client_config
}

pub fn configure_interactive(args_ MailClientConfig) ! {
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

@[params]
pub struct SendArgs {
pub mut:
	markdown  bool
	from      string
	to        string
	cc        string
	bcc       string
	date      time.Time = time.now()
	subject   string
	body_type BodyType
	body      string
}

enum BodyType {
	text
	html
	markdown
}

// ```
// cl.send(markdown:true,subject:'this is a test',to:'kds@something.com,kds2@else.com',content:'
//     this is my email content
//     ')
// args:
// 	markdown  bool
// 	from      string
// 	to        string
// 	cc        string
// 	bcc       string
// 	date      time.Time = time.now()
// 	subject   string
// 	body_type BodyType (.html, .text, .markdown)
// 	body      string
// ```
pub fn (mut cl MailClient) send(args_ SendArgs) ! {
	mut args := args_
	args.body = texttools.dedent(args.body)
	mut body_type := smtp.BodyType.text
	if args.body_type == .html || args.body_type == .markdown {
		body_type = smtp.BodyType.html
	}
	mut m := smtp.Mail{
		from: args.from
		to: args.to
		cc: args.cc
		bcc: args.bcc
		date: args.date
		subject: args.subject
		body: args.body
		body_type: body_type
	}

	return cl.smtp_client.send(m)
}
