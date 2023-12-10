module mediacms

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers

@[params]
pub struct BuildArgs {
pub mut:
	reset bool
}

// install mediacms will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	// install mediacms if it was already done will return true
	println(' - build mediacms')

	// gitpath := gittools.code_get(
	// 	coderoot: '/tmp/builder'
	// 	url: mediacms.url
	// 	reset: true
	// 	pull: true
	// )!

	// cmd := '
	// source ${osal.profile_path()} //source the go path
	// cd ${gitpath}
	// go build -o bin/ ./cmd/...

	// cp /tmp/builder/github/matrix-org/mediacms/bin/mediacms /usr/local/bin/mediacms
	// cp /tmp/builder/github/matrix-org/mediacms/bin/generate-keys /usr/local/bin/mediacms-generate-keys
	// cp /tmp/builder/github/matrix-org/mediacms/bin/create-account /usr/local/bin/mediacms-create-account
	// cp /tmp/builder/github/matrix-org/mediacms/bin/furl /usr/local/bin/furl

	// '
	// osal.execute_stdout(cmd)!
}
