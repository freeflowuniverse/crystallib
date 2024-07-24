#!/usr/bin/env -S v -n -w -enable-globals run

import flag
import os
import log
import freeflowuniverse.crystallib.clients.sendgrid { new_client }

mut logger := log.Log{}
logger.set_level(.info)

mut fp := flag.new_flag_parser(os.args)
fp.application('SendGrid example')
fp.description('Example of using sendgrid client to send emails')
fp.skip_executable()

token := fp.string('token', `t`, os.getenv('SENDGRID_AUTH_TOKEN'), 'SendGrid API Key')
debug := fp.bool('debug', `d`, false, 'enable debug mode')

fp.finalize() or {
	logger.error(err.msg())
	exit(1)
}

if debug {
	logger.set_level(.debug)
}

mut client := new_client(token) or {
	logger.error('failed to create a new sendgrid client: ${err}')
	exit(1)
}

email := sendgrid.new_email(['target_email@example.com', 'target_email2@example.com'],
	'source_email@example.com', 'Hello from Crystallib', '<h2>Hello from Twilio SendGrid via crystallib!</h2><p>Sending with the email service trusted by developers and marketers for <strong>time-savings</strong>, <strong>scalability</strong>, and <strong>delivery expertise</strong>.</p>')

client.send(email) or {
	logger.error('failed to send the email: ${err}')
	exit(1)
}

logger.debug('email sent successfully')
