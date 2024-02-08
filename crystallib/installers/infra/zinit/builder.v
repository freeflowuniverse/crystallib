module zinit

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.installers

const url = 'https://github.com/threefoldtech/zinit.git'

@[params]
pub struct BuildArgs {
pub mut:
	reset    bool
	bin_push bool = true
}

// install zinit will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return
	}
	base.install()!
	rust.install()!

	// install zinit if it was already done will return true
	console.print_header('build zinit')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: zinit.url, reset: true, pull: true)!

	// source ${osal.profile_path()}

	cmd := '
	source ~/.cargo/env
	cd ${gitpath}
	make release
	'
	osal.execute_stdout(cmd)!

	osal.cmd_add(
		cmdname: 'zinit'
		source: '/tmp/builder/github/threefoldtech/zinit/target/x86_64-unknown-linux-musl/release/zinit'
	)!
}
