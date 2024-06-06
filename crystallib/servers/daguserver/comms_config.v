module daguserver

import os

@[params]
pub struct DaguCommunicationConfig {
pub:
	log_dir                string // directory path to save logs from standard output
	history_retention_days int    // history retention days (default: 30)
	mail_on                MailOn // Email notification settings
	smtp                   SMTP   // SMTP server settings
	error_mail             Mail   // Error mail configuration
	info_mail              Mail   // Info mail configuration
}

pub struct SMTP {
pub:
	host       string
	port       string
	username   string
	password   string
	error_mail Mail
}

pub struct Mail {
pub:
	from   string
	to     string
	prefix string
}

pub struct MailOn {
pub:
	failure bool
	success bool
}

pub fn (mut self DaguServer[Config]) comms_configure(config DaguCommunicationConfig) ! {
	mut homedir := self.config()!.homedir

	config_yaml := $tmpl('./templates/config.yaml')
	os.write_file('${homedir}/config.yaml', config_yaml)!

	dags_dir := '${homedir}/dags'
	if !os.exists(dags_dir) {
		os.mkdir(dags_dir)!
	}
}
