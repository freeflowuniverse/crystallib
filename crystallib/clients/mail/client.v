module mail

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.texttools
import net.smtp
import time

pub struct MailClient {
	play.BaseConfig
pub mut:
	smtp_client smtp.Client
}

// pub fn get(args play.PlayArgs) !MailClient {
// 	panic("implement using new way how to do the config mgmt")
println(args)
mut smtp_client := smtp.new_client(
	server: args.smtp_addr
	port: args.smpt_port
	username: args.smtp_login
	password: args.smtp_passwd
	from: args.mail_from
	ssl: args.ssl
	starttls: args.starttls
)!
println(smtp_client)
mut client := MailClient{
	instance: args.instance
	smtp_client: smtp_client
	session: plargs.session
}
// 	return client
// }

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
