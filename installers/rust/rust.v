module rust

import freeflowuniverse.crystallib.osal
// install rust will return true if it was already installed

pub fn install() ! {
	// install rust if it was already done will return true
	println(' - package_install install rust')
	// TODO: install_rust was in done_exists
	if osal.done_exists('install_rust') {
		println('    package_install was already done')
		return
	}

	if osal.cmd_exists('rustup') && osal.cmd_exists('cargo') {
		println('Rust was already installed.')
		return
	}
	// curl --proto '=https' --tlsv1.2 https://sh.rustup.rs | sh -s -- -y
	osal.execute_silent("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")!
	

	println(" IMPORTANT: TO USE DO: \nsource \$HOME/.cargo/env")

	// return error('Cannot setup rust.\n')

	// path := "export PATH='/usr/bin:/bin:/root/.cargo/bin'"
	// osal.execute_silent("echo $path >> .bash_profile") or {
	// 	return error('Cannot add path to .bash_profile: $err')
	// }
	// osal.execute_silent("echo $path >> .bashrc") or {
	// 	return error('Cannot add path to .bashrc: $err')
	// }

	osal.done_set('install_rust', 'OK')!
	return
}
