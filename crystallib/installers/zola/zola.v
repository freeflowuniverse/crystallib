module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.rust

[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install zola will return true if it was already installed
pub fn install(args InstallArgs) ! {
	// make sure we install base on the node
	base.install()!

	if args.reset == false && osal.done_exists('install_zola') {
		return
	}

	// install zola if it was already done will return true
	println(' - install zola')

	mut url := ''
	if osal.is_ubuntu() {
		url = 'https://github.com/getzola/zola/releases/download/v0.17.2/zola-v0.17.2-x86_64-unknown-linux-gnu.tar.gz'
	} else if osal.is_osx_arm() {
		url = 'https://github.com/getzola/zola/releases/download/v0.17.2/zola-v0.17.2-x86_64-apple-darwin.tar.gz'
	} else {
		return error('only support ubuntu & osx arm for now')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 5000
		reset: true
		expand_dir: '/tmp/zolaserver'
	)!

	mut zolafile := dest.file_get('zola')! // file in the dest

	osal.bin_copy(
		// cmdname: ''
		source: zolafile.path
	)!

	println(' zola INSTALLED')

	osal.done_set('install_zola', 'OK')!
	return
}

// install zola will return true if it was already installed
pub fn build() ! {
	rust.install()!
	println(' - install zola')
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
		println(' - zola installed')
	} else {
		println(' - zola already installed')
	}
}

// https://www.getzola.org/documentation/getting-started/installation/
