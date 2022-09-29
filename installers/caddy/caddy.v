module caddy

// install caddy will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install caddy if it was already done will return true
	println(' - $node.name: install caddy')
	if !(i.state == .reset) && node.done_exists('install_caddy') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('caddy') {
		println('Caddy was already installed.')
		//? should we set caddy as done here ?
		return
	}

	node.exec("
		sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
		curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
		sudo apt update
		sudo apt install caddy
	") or {
		return error('Cannot install caddy.\n$err')
	}

	node.done_set('install_caddy', 'OK')?
	return
}
