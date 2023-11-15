module rclone

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.golang
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers

const url = 'https://github.com/rclone/rclone'

[params]
pub struct BuildArgs {
pub mut:
	reset    bool
	bin_push bool = true
}

// install rclone will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	golang.install()!

	// install rclone if it was already done will return true
	println(' - build rclone')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: rclone.url, reset: true, pull: true)!

	cmd := '

	cd ${gitpath}
	exit 1 #todo
	'
	osal.execute_stdout(cmd)!

	// if args.bin_push {
	// 	installers.bin_push(
	// 		cmdname: 'rclone'
	// 		source: '/tmp/builder/github/threefoldtech/rclone/target/x86_64-unknown-linux-musl/release/rclone'
	// 	)!
	// }
}
