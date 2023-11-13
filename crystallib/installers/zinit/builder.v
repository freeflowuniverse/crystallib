module zinit

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers

const url = 'https://github.com/threefoldtech/zinit.git'

[params]
pub struct BuildArgs {
pub mut:
	reset    bool
	bin_push bool = true
}

// install zinit will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	base.install()!
	rust.install()!

	// install zinit if it was already done will return true
	println(' - build zinit')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: zinit.url, reset: true, pull: true)!

	cmd := '

	cd ${gitpath}
	make
	'
	osal.execute_stdout(cmd)!

	// if args.bin_push {
	// 	installers.bin_push(
	// 		cmdname: 'zinit'
	// 		source: '/tmp/builder/github/threefoldtech/zinit/target/x86_64-unknown-linux-musl/release/zinit'
	// 	)!
	// }
}
