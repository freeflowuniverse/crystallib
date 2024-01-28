module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.installers.web.tailwind
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install zola will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '0.18.0'

	res := os.execute('${osal.profile_path_source_and()} zola -V')
	if res.exit_code == 0 {
		v := texttools.version(res.output)
		if v < texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	// install zola if it was already done will return true
	console.print_header('install Zola')

	// make sure we install base on the node
	base.install()!
	tailwind.install()!

	mut url := ''
	if osal.is_linux() {
		url = 'https://github.com/getzola/zola/releases/download/v0.18.0/zola-v${version}-x86_64-unknown-linux-gnu.tar.gz'
	} else if osal.is_osx_arm() {
		url = 'https://github.com/getzola/zola/releases/download/v0.18.0/zola-v${version}-aarch64-apple-darwin.tar.gz'
	} else if osal.is_osx_intel() {
		url = 'https://github.com/getzola/zola/releases/download/v0.18.0/zola-v${version}-x86_64-apple-darwin.tar.gz'
	} else {
		return error('unsupported platform')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 5000
		reset: true
		expand_dir: '/tmp/zolaserver'
	)!

	mut zolafile := dest.file_get('zola')! // file in the dest

	osal.cmd_add(
		source: zolafile.path
	)!

	console.print_header('Zola Installed')

	return
}

// install zola will return true if it was already installed
pub fn build() ! {
	rust.install()!
	console.print_header('install zola')
	if !osal.done_exists('install_zola') && !osal.cmd_exists('zola') {
		// USE OUR PRIMITIVES (TODO, needs to change)
		cmd := '
		source ~/.cargo/env
		cd /tmp
		rm -rf zola
		git clone https://github.com/getzola/zola.git
		cd zola
		cargo install --path . --locked
		zola --version
		cargo build --release --locked --no-default-features --features=native-tls
		cp target/release/zola ~/.cargo/bin/zola
		'
		osal.execute_stdout(cmd)!
		osal.done_set('install_zola', 'OK')!
		console.print_header('zola installed')
	} else {
		console.print_header('zola already installed')
	}
}

// https://www.getzola.org/documentation/getting-started/installation/
