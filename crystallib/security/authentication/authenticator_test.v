module authentication

import log
import os
import net.smtp
import toml
import freeflowuniverse.crystallib.osal

fn testsuite_begin() {
	osal.load_env_file(os.dir(@FILE) + '/testdata/.env') or {
		panic('Could not find .env, ${err}')
	}
}

fn test_new() {
	authenticator := new(
		secret: 'abcd'
		smtp_client: get_test_smtp_client()
	)!
}

fn test_send_verification_mail() {
	mut authenticator := new(
		secret: 'abcd'
		smtp_client: get_test_smtp_client()
	)!

	verification_mail := VerificationMail{
		subject: 'test_send_verification_mail'
		body: 'Test body'
	}

	authenticator.send_verification_mail(
		email: os.getenv('TEST_EMAIL')
		mail: verification_mail
		link: 'https://example.com'
	)!
}

fn get_test_smtp_client() smtp.Client {
	return smtp.Client{
		server: 'smtp-relay.brevo.com'
		from: os.getenv('TEST_EMAIL')
		port: 587
		username: os.getenv('BREVO_SMTP_USERNAME')
		password: os.getenv('BREVO_SMTP_PASSWORD')
	}
}
