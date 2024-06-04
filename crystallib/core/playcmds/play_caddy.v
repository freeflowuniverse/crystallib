module playcmds

import freeflowuniverse.crystallib.servers.caddy {Address, ReverseProxy, SiteBlock}
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import os

pub fn play_caddy(mut plbook playbook.PlayBook) ! {
	mut coderoot := ''
	// mut install := false
	mut reset := false
	mut pull := false

	mut config_actions := plbook.find(filter: 'caddy.configure')!

	mut c := caddy.get('')!

	if config_actions.len > 1 {
		return error('can only have 1 config action for books')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		path := p.get_default('path', '/etc/caddy')!
		url := p.get_default('url', '')!
		
		mut cfg := c.config()!
		cfg.path = path
		cfg.url = url
		config_actions[0].done = true
	}

	for mut action in plbook.find(filter: 'caddy.reverse_proxy')! {
		mut p := action.params
		host := p.get_default('host', '')!
		port := p.get_int_default('port', 0)!
		description := p.get_default('description', '')!
		local_port := p.get_int_default('local_port', 0)!
		local_url := p.get_default('local_url', 'http://localhost')!
		local_path := p.get_default('local_path', '')!
		
		c.reverse_proxy(
			address: Address {
				domain: host
				port: port
				description: description
			},
			reverse_proxy: [ReverseProxy{
				path: local_path
				url: local_url
			}]
		)!
		action.done = true
	}

	for mut action in plbook.find(filter: 'caddy.generate')! {
		c.generate()!
		action.done = true
	}
}
