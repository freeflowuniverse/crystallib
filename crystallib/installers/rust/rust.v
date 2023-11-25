module rust

import os
import freeflowuniverse.crystallib.osal
// install rust will return true if it was already installed

pub fn install() ! {
	// install rust if it was already done will return true
	println(' - start install rust')

	// osal.done_delete('install_rust')!

	if osal.done_exists('install_rust') {
		println(' - rust was already installed')
		return
	}

	osal.execute_stdout("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")!

	osal.profile_path_add("${os.home_dir()}/.cargo/bin")!

	osal.done_set('install_rust', 'OK')!
	return
}
