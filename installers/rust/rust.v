module rust

// install rust will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install rust if it was already done will return true
	println(' - $node.name: install rust')
	if !(i.state == .reset) && node.done_exists('install_rust') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('rustup') {
		println('Rust was already installed.')
		//? should we set rust as done here ?
		return
	}

	node.exec("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh") or {
		return error('Cannot install rust.\n$err')
	}

	node.done_set('install rust', 'OK')?
	return
}
