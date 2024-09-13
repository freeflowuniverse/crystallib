module main

import freeflowuniverse.spiderlib.auth.email
import os
import time
import toml

pub fn (mut app EmailApp) verify_email(address string) !bool {
	env := toml.parse_file(os.dir(os.dir(os.dir(@FILE))) + '/.env') or {
		panic('Could not find .env, ${err}')
	}
	lock app.auth {
		app.auth.send_verification_mail(
			email: address
			link: 'http://localhost:8080/authentication_link'
			smtp: email.SmtpConfig{
				server: env.value('SMTP_SERVER').string()
				from: 'verify@authenticator.io'
				port: env.value('SMTP_PORT').int()
				username: env.value('SMTP_USERNAME').string()
				password: env.value('SMTP_PASSWORD').string()
			}
			mail: email.VerificationMail {}
		) or {
			panic(err)
		}
	}
	// checks if email verified every 2 seconds
	for {
		lock app.auth {
			authenticated := app.auth.is_authenticated(address) or {
				panic(err)
			}
			if authenticated {
				// returns success message once verified
				println('returning true')
				return true
			}
		}
		time.sleep(2 * time.second)
	}
	println('returning false')
	return false
}

pub fn (mut app EmailApp) authenticate(address string, cypher string) bool {
	lock app.auth {
		app.auth.authenticate(address, cypher) or {
			return false
		}
		return true
	}
	return false
}

