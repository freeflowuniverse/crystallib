module rust

// install rust will return true if it was already installed
pub fn (mut i Installer) install() ! {
	mut node := i.node
	// install rust if it was already done will return true
	println(' - $node.name: install rust')
	// TODO: install_rust was in done_exists
	if !(i.state == .reset) && node.done_exists('install_rust') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('rustup') && node.command_exists('cargo') {
		println('Rust was already installed.')
		return
	}
	// curl --proto '=https' --tlsv1.2 https://sh.rustup.rs | sh -s -- -y
	node.exec("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y") or {
		return error('Cannot install rust.\n$err')
	}

	node.exec('source .cargo/env') or { return error('Cannot setup rust.\n$err') }

	// path := "export PATH='/usr/bin:/bin:/root/.cargo/bin'"
	// node.exec("echo $path >> .bash_profile") or {
	// 	return error('Cannot add path to .bash_profile: $err')
	// }
	// node.exec("echo $path >> .bashrc") or {
	// 	return error('Cannot add path to .bashrc: $err')
	// }

	node.done_set('install_rust', 'OK')!
	return
}
