module caddy

import installers.base

// install caddy will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install caddy if it was already done will return true
	println(' - $node.name: install caddy')
	if !(i.state == .reset) && node.done_exists('install_caddy') {
		println('    $node.name: was already done')
		return
	}

	if node.platform != .ubuntu {
		return error('only support ubuntu for now')
	}

	base.get_install(mut node)?

	if node.command_exists('caddy') {
		println('Caddy was already installed.')
		//? should we set caddy as done here ?
		return
	}

	node.exec("
		sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https gpg sudo
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
		apt update
		apt install caddy
	") or {
		return error('Cannot install caddy.\n$err')
	}

	node.done_set('install_caddy', 'OK')?
	return
}

// configure caddy as default webserver & start
pub fn (mut i Installer) configure_webserver_default(path string) ? {
	mut node := i.node

	mut config_file := $tmpl('templates/caddyfile_default')

	return
}
