module main

import freeflowuniverse.crystallib.installers.mediacms

fn do() ! {
	mediacms.build(
		name: 'default'
		reset: true
		dest: '/data/mediacms'
		passwd: 'mypasswd'
		postgresql_name: 'mediacms'
		domain: 'mydomain.com'
		title: 'my title'
		timezone: 'Africa/Kinshasa'
		mail_from: ''
		smtp_addr: ''
		smtp_login: ''
		smtp_port: 587
		smtp_passwd: ''
	)!
}

fn main() {
	do() or { panic(err) }
}
