module email

import time
import crypto.hmac
import crypto.sha256
import encoding.hex
import encoding.base64
import freeflowuniverse.crystallib.clients.mailclient {MailClient}

pub struct StatelessAuthenticator {
pub:
	secret string
pub mut:
 	mail_client MailClient
}

 pub fn new_stateless_authenticator(authenticator StatelessAuthenticator) !StatelessAuthenticator {
	// TODO: do some checks
 	return StatelessAuthenticator {...authenticator}
}

pub struct AuthenticationMail {
pub:
	to string // email address being authentcated
 	from    string = 'email_authenticator@crystallib.tf'
 	subject string = 'Verify your email'
 	body    string = 'Please verify your email by clicking the link below'
	callback string // callback url of authentication link
}

pub fn (mut a StatelessAuthenticator) send_authentication_mail(mail AuthenticationMail) ! {
	link := a.new_authentication_link(mail.to, mail.callback)!
	button := '<a href="${link}" style="display:inline-block; padding:10px 20px; font-size:16px; color:white; background-color:#4CAF50; text-decoration:none; border-radius:5px;">Verify Email</a>'

 	// send email with link in body
 	a.mail_client.send(
		to: mail.to
 		from: mail.from
 		subject: mail.subject
 		body_type: .html
 		body: $tmpl('./templates/mail.html')
	) or { panic('Error resolving email address $err') }
}

fn (a StatelessAuthenticator) new_authentication_link(email string, callback string) !string {
	// sign email address and expiration of authentication link
	expiration := time.now().add(5 * time.minute)
 	data := '${email}.${expiration}' // data to be signed
 	signature := hmac.new(
 		hex.decode(a.secret)!,
 		data.bytes(),
 		sha256.sum,
 		sha256.block_size
 	)
 	encoded_signature := base64.url_encode(signature.bytestr().bytes())
	return "${callback}/${email}/${expiration.unix_time()}/${encoded_signature}"
}

pub struct AuthenticationAttempt {
pub:
 	email string
 	expiration time.Time
 	signature string
}

// sends mail with login link
pub fn (auth StatelessAuthenticator) authenticate(attempt AuthenticationAttempt) ! {	
 	if time.now() > attempt.expiration {
 		return error('link expired')
 	}

 	data := '${attempt.email}.${attempt.expiration}' // data to be signed
 	signature_mirror := hmac.new(
 		hex.decode(auth.secret) or {panic(err)},
 		data.bytes(),
 		sha256.sum,
 		sha256.block_size
 	).bytestr().bytes()

 	decoded_signature := base64.url_decode(attempt.signature)

 	if !hmac.equal(decoded_signature, signature_mirror) {
 		return error('signature mismatch')
 	}
}
