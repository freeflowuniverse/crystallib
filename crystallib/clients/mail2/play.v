module mail

import freeflowuniverse.crystallib.core.playbook

pub fn heroplay(mut plbook playbook.PlayBook) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'mailclient.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		cfg.description = p.get_default('description', 'mailclient')!
		cfg.mail_from = p.get('mail_from')!
		cfg.smtp_addr = p.get('smtp_addr')!
		cfg.smtp_login = p.get('smtp_login')!
		cfg.smtp_port = p.get_int('smtp_port')!
		cfg.smtp_passwd = p.get('smtp_passwd')!
		cfg.ssl = p.get_default_false('ssl')
		cfg.starttls = p.get_default_true('startssl')
		cl.config_save()!
	}
}
