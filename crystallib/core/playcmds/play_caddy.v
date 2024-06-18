module playcmds

import freeflowuniverse.crystallib.servers.caddy { Address, ReverseProxy }
import freeflowuniverse.crystallib.core.playbook

pub fn play_caddy(mut plbook playbook.PlayBook) ! {
	mut coderoot := ''
	// mut install := false
	mut reset := false
	mut pull := false

	mut config_actions := plbook.find(filter: 'caddy.configure')!

	mut c := caddy.get('')!

	mut public_ip := ''

	if config_actions.len > 1 {
		return error('can only have 1 config action for books')
	} else if config_actions.len == 1 {
		mut p := config_actions[0].params
		path := p.get_default('path', '/etc/caddy')!
		url := p.get_default('url', '')!

		mut cfg := c.config()!
		cfg.homedir = path
		cfg.url = url
		config_actions[0].done = true
		public_ip = p.get_default('public_ip', '')!
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
			addresses: [Address{
				domain: host
				port: port
				description: description
			}]
			reverse_proxy: [
				ReverseProxy{
					path: local_path
					url: local_url
				},
			]
		)!
		action.done = true
	}

	for mut action in plbook.find(filter: 'caddy.serve_folder')! {
		mut p := action.params
		
		url := p.get_default('url', '')!
		serve_public_ip := p.get_default_true('public_ip')
		https := p.get_default_false('https')
		port := p.get_int_default('port', 8000)!
		mut path := p.get_default('path', '')!
		description := p.get_default('description', '')!

		if path.starts_with('~') { 
			path = '${os.home_dir()}${path.trim_string_left('~')}'
		}

		mut addresses := []caddy.Address
		if url != '' {
			addresses << Address {
				domain: url.all_before_last(':')
				port: url.all_after_last(':').int()
			}
		}

		prefix := if https { 'https'} else {'http'}

		if serve_public_ip {
			addresses << Address {
				domain: '${prefix}://${public_ip}'
				port: port
			}
		}

		c.add_block(
			addresses: addresses
			file_server: [caddy.FileServer {
				path: path
			}]
		)!
		action.done = true
	}

	for mut action in plbook.find(filter: 'caddy.generate')! {
		c.generate()!
		action.done = true
	}

	for mut action in plbook.find(filter: 'caddy.start')! {
		c.restart()!
		action.done = true
	}
}
