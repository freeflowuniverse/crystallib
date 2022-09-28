module vlang

// install vlang will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install vlang if it was already done will return true
	panic("implement")
	println(' - $node.name: install vlang')
	if !(i.state == .reset) && node.done_exists('install_vlang') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('vlangup') {
		println('Rust was already installed.')
		//? should we set vlang as done here ?
		return
	}

	node.exec("curl --proto '=https' --tlsv1.2 -sSf https://sh.vlangup.rs | sh") or {
		return error('Cannot install vlang.\n$err')
	}

	node.done_set('install vlang', 'OK')?
	return
}
