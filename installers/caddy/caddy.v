module caddy

// install caddy will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install caddy if it was already done will return true
	panic("implement")
	println(' - $node.name: install caddy')
	if !(i.state == .reset) && node.done_exists('install_caddy') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('caddy') {
		println('Rust was already installed.')
		//? should we set caddy as done here ?
		return
	}

	node.exec("curl --proto '=https' --tlsv1.2 -sSf https://sh.caddyup.rs | sh") or {
		return error('Cannot install caddy.\n$err')
	}

	node.done_set('install_caddy', 'OK')?
	return
}
