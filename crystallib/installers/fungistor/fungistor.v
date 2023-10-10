module fungistor

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.osal.gittools

pub fn install() ! {
	rust.install()!
	println(' - install fungistor')
	if !osal.done_exists('install_fungistor') && !osal.cmd_exists('rst') {
		mut gs := gittools.new(root: '/tmp/code')!
		url := 'https://github.com/threefoldtech/rfs'
		mut gr := gs.repo_get_from_url(url: url, pull: false, reset: false)!
		mut path := gr.path_content_get()

		cmd := '
		cd ${path}
		rustup target add x86_64-unknown-linux-musl
		cargo build --features build-binary --release --target=x86_64-unknown-linux-musl

		'
		osal.execute_silent(cmd)!
		osal.done_set('install_fungistor', 'OK')!
	}
	println(' - fungistor already done')
}
