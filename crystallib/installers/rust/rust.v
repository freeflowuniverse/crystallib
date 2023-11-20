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

	// if osal.cmd_exists('rustup') && osal.cmd_exists('cargo') {
	// 	return
	// }
	// curl --proto '=https' --tlsv1.2 https://sh.rustup.rs | sh -s -- -y
	osal.execute_stdout("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")!

	// println(' IMPORTANT: TO USE DO: \nsource \$HOME/.cargo/env')

	// return error('Cannot setup rust.\n')

	// path := "export PATH='/usr/bin:/bin:/root/.cargo/bin'"
	osal.execute_silent("echo 'source ${os.home_dir()}/.cargo/env' >> ${os.home_dir()}/.profile") or {
		return error('Cannot add path to .profile: ${err}')
	}
	// osal.execute_silent("echo $path >> .bashrc") or {
	// 	return error('Cannot add path to .bashrc: $err')
	// }

	osal.done_set('install_rust', 'OK')!
	return
}
