module dendrite

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.golang
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers

const url = 'https://github.com/matrix-org/dendrite'

[params]
pub struct BuildArgs {
pub mut:
	reset    bool
}

// install dendrite will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	golang.install()!

	// install dendrite if it was already done will return true
	println(' - build dendrite')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: dendrite.url, reset: true, pull: true)!

	cmd := '

	cd ${gitpath}
	go build -o bin/ ./cmd/...
	exit 1 #todo
	'
	osal.execute_stdout(cmd)!

	// osal.bin_copy(
	// 	cmdname: 'dendrite'
	// 	source: binpath.path
	// )!	


}
