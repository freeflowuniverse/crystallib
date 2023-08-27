module main

import freeflowuniverse.crystallib.sms { new }
import os
import log

fn main() {
	sid := os.getenv("TWILIO_ACCOUNT_SID")
	token := os.getenv("TWILIO_AUTH_TOKEN")
	source := os.getenv("TWILIO_NUMBER")

	mut logger := log.Log{}
	logger.set_level(.info)

	cred := sms.Credentials{
		sid: sid
		token: token
		source: source
	}
	mut client := new(cred, mut logger)!

	msg := sms.Message{
		content: "hello_world"
		destination: "+201005001050"
	}

	res := client.send(msg) or {
		client.logger.error("failed to send message: ${err}")
	}

	if res.level == "error" {
		client.logger.error("${res.content}: ${res.more_info}")
	} else {
		client.logger.info("${res.content}: ${res.more_info}")
	}

}