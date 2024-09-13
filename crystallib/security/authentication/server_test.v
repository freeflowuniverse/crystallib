module authentication

import json
import log
import net.smtp
import net.http
import os
import toml
import freeflowuniverse.crystallib.osal

const test_base_url = 'http://someurl.com'
const test_callback_url = 'http://anotherurl.com/callback'

fn testsuite_begin() {
	osal.load_env_file(os.dir(@FILE) + '/testdata/.env') or {
		panic('Could not find .env, ${err}')
	}
}

fn test_new_server() {
	client := get_test_smtp_client()

	server := new_server(
		secret: 'abcd'
		smtp_client: client
		base_url: test_base_url
	)!
}

fn test_send_verification_mail() {
	client := get_test_smtp_client()

	mut server := new_server(
		secret: 'abcd'
		smtp_client: client
		base_url: test_base_url
	)!

	send_mail_config := SendMailConfig{
		email: os.getenv('TEST_EMAIL')
		mail: VerificationMail{
			from: os.getenv('TEST_EMAIL')
		}
		callback: test_callback_url
	}
	mut context := Context {
		req: http.Request {
			data: json.encode(send_mail_config)
		}
	}

	server.send_verification_mail(mut context)!
}

fn test_authentication_link() {
	client := get_test_smtp_client()
	mut server := new_server(
		secret: 'abcd'
		smtp_client: client
		base_url: test_base_url
	)!
	mut context := Context {}
	server.authentication_link(mut context, os.getenv('TEST_EMAIL'), 'cypher', 'callback')!
}

fn test_server_run() {
	client := get_test_smtp_client()
	mut server := new_server(
		secret: 'abcd'
		smtp_client: client
		base_url: test_base_url
	)!
	spawn (&server).run(8080)
}

fn get_test_smtp_client() smtp.Client {
	return smtp.Client{
		server: 'smtp-relay.brevo.com'
		from: 'timur@incubaid.com'
		port: 587
		username: os.getenv('BREVO_SMTP_USERNAME')
		password: os.getenv('BREVO_SMTP_PASSWORD')
	}
}
