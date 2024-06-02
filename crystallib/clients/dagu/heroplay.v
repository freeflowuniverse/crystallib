module dagu

import freeflowuniverse.crystallib.core.playbook

pub fn heroplay(mut plbook playbook.PlayBook) ! {
	for mut action in plbook.find(filter: 'daguclient.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance)!
		mut cfg := cl.config_get()!
		cfg.url = p.get('url')!
		cfg.username = p.get('username')!
		cfg.password = p.get('password')!
		cl.config_save()!
	}
}
