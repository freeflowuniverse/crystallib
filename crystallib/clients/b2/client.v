module B2

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.lang.python

pub struct B2Client {
	play.Base
pub mut:
	py 
}

@[params]
pub struct ClientArgs {
pub mut:
	instance string         @[required]
	playargs ?play.PlayArgs
}

pub fn get(clientargs ClientArgs) !B2Client {
	mut plargs := clientargs.playargs or { play.PlayArgs{} }
	mut cfg := 
	args := cfg.get()!

	mut py := python.new(name: 'default')! // a python env with name test
	py.update()!

	// println(smtp_client)
	mut client := B2Client{
		instance: args.instance
		session: plargs.session
		config: configurator(clientargs.instance, plargs)!
	}
	return client
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
//     this is my eB2 content
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
pub fn (mut cl B2Client) send(args_ SendArgs) ! {
	mut args := args_
	args.body = texttools.dedent(args.body)
	mut body_type := smtp.BodyType.text
	if args.body_type == .html || args.body_type == .markdown {
		body_type = smtp.BodyType.html
	}
	mut m := smtp.B2{
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
