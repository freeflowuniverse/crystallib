module zinit

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import os

const url="https://github.com/threefoldtech/zinit.git"

// install zinit will return true if it was already installed
pub fn build(args InstallArgs) ! {
	// make sure we install base on the node
	base.install()!
	rust.install()!

	// install zinit if it was already done will return true
	println(' - build zinit')

	gitpath:=gittools.code_get(coderoot:"/tmp/builder",url:url,reset:true)!

	cmd := '
	cd ${gitpath}
	make
	'
	osal.execute_silent(cmd)!

	// if osal.platform() != .ubuntu {
	// 	return error('only support ubuntu for now')
	// }



	return
}

