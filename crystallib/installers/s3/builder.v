module s3cas

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools

import freeflowuniverse.crystallib.installers

[params]
pub struct BuildArgs {
pub mut:
	reset bool
	bin_push bool = true
}


// install s3cas will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}	
	rust.install()!

	// install s3cas if it was already done will return true
	println(' - build s3cas')

	osal.package_install("libssl-dev,pkg-config")!

	path := gittools.code_get(url: 'https://github.com/leesmet/s3-cas', reset: false, pull: true)!
	cmd := '
	set -ex
	cd ${path}
	cargo build --all-features
	'
	osal.execute_stdout(cmd) or { return error('Cannot install s3.\n${err}') }

	if args.bin_push{
		installers.bin_push(cmdname:"s3-cas",source:'/root/code/github/leesmet/s3-cas/target/debug/s3-cas')!		
	}
}
