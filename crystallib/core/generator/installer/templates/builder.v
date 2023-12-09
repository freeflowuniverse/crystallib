module ${args.name}

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.installers
@if args.build_deps == .rust
import freeflowuniverse.crystallib.installers.rust
@end


@[params]
pub struct BuildArgs {
pub mut:
	reset bool
}

// install ${args.name} will return true if it was already installed
pub fn build(args BuildArgs) ! {

	checkplatform()!
	
	base.install()

	@if args.build_deps == .rust
	rust.install()!
	@end
	
	// install ${args.name} if it was already done will return true
	println(' - build ${args.name}')

	// mut gs := gittools.get()!

	// mut gitpath := gittools.code_get(
	// 	url: "https://github.com/xxxx/yyy"
	// 	pull: true
	// 	reset: true
	// )!

	// cmd := '
	// source @@{osal.profile_path()} //source the go path
	// cd @@{gitpath}


	// '
	// osal.execute_stdout(cmd)!


}
