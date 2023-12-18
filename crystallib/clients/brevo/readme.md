	mail_from       string = 'git@meet.tf'
	smtp_addr       string = 'smtp-relay.brevo.com'
	smtp_login      string @[required]
	smpt_port       int = 587
	smtp_passwd     string