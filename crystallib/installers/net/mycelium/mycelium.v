
module mycelium

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.installers.web.tailwind
import freeflowuniverse.crystallib.ui.console
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install mycelium will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	mut args := args_

	// res := os.execute('source ${osal.profile_path()} && mycelium -V')
	// if res.exit_code == 0 {
	// 	if !(res.output.contains('0.17.2')) {
	// 		args.reset = true
	// 	}
	// } else {
	// 	args.reset = true
	// }

	// if args.reset == false && osal.done_exists('install_mycelium') {
	// 	return
	// }

	// install mycelium if it was already done will return true
	console.print_header('install mycelium')

	mut url := ''
	if osal.is_linux() {
		url = 'https://github.com/threefoldtech/mycelium/releases/download/v0.2.3/mycelium-aarch64-unknown-linux-musl.tar.gz'
	} else if osal.is_osx_arm() {
		url = 'https://github.com/threefoldtech/mycelium/releases/download/v0.2.3/mycelium-aarch64-apple-darwin.tar.gz'
	} else {
		return error('only support ubuntu & osx arm for now')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 1000
		reset: true
		expand_dir: '/tmp/myceliumserver'
	)!

	mut myceliumfile := dest.file_get('mycelium')! // file in the dest

	osal.cmd_add(
		source: myceliumfile.path
	)!

	println(' mycelium INSTALLED')

	osal.done_set('install_mycelium', 'OK')!
	return
}

// install mycelium will return true if it was already installed
pub fn build() ! {
	rust.install()!
	console.print_header('build mycelium')
	if !osal.done_exists('build_mycelium') && !osal.cmd_exists('mycelium') {
		panic("implement")
		// USE OUR PRIMITIVES (TODO, needs to change, was from zola)
		cmd := '
		source ~/.cargo/env
		cd /tmp
		rm -rf mycelium
		git clone https://github.com/getmycelium/mycelium.git
		cd mycelium
		cargo install --path . --locked
		mycelium --version
		cargo build --release --locked --no-default-features --features=native-tls
		cp target/release/mycelium ~/.cargo/bin/mycelium
		'
		osal.execute_stdout(cmd)!
		osal.done_set('build_mycelium', 'OK')!
		console.print_header('mycelium installed')
	} else {
		console.print_header('mycelium already installed')
	}
}

