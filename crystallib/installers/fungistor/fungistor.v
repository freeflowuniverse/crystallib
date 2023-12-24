module fungistor

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers.zinit

pub fn install() ! {
	rust.install()!
	zinit.install()!
	println(' - install fungistor')
	if !osal.done_exists('install_fungistor') || !osal.cmd_exists('rfs') {
		osal.package_install('musl-dev,musl-tools')!

		path := gittools.code_get(url: 'https://github.com/threefoldtech/rfs', reset: true)!
		cmd := '
		cd ${path}
		rustup target add x86_64-unknown-linux-musl
		cargo build --features build-binary --release --target=x86_64-unknown-linux-musl

		cp ~/code/github/threefoldtech/rfs/target/x86_64-unknown-linux-musl/release/rfs /usr/local/bin/
		'
		println(' - build fungistor')
		osal.execute_stdout(cmd)!
		osal.done_set('install_fungistor', 'OK')!
	}
	println(' - fungistor already done')
}
