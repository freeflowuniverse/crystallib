module dendrite

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.golang
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers

const url = 'https://github.com/matrix-org/dendrite'

@[params]
pub struct BuildArgs {
pub mut:
	reset bool
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

	gitpath := gittools.code_get(
		coderoot: '/tmp/builder'
		url: dendrite.url
		reset: true
		pull: true
	)!

	cmd := '
	source ${osal.profile_path()} //source the go path
	cd ${gitpath}
	go build -o bin/ ./cmd/...

	cp /tmp/builder/github/matrix-org/dendrite/bin/dendrite /usr/local/bin/dendrite
	cp /tmp/builder/github/matrix-org/dendrite/bin/generate-keys /usr/local/bin/dendrite-generate-keys
	cp /tmp/builder/github/matrix-org/dendrite/bin/create-account /usr/local/bin/dendrite-create-account
	cp /tmp/builder/github/matrix-org/dendrite/bin/furl /usr/local/bin/furl

	'
	osal.execute_stdout(cmd)!
}
