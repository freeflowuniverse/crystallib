module base

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import os


pub fn nix_install(args InstallArgs) ! {
	console.print_header('nix prepare')
	pl := osal.platform()

	if args.reset == false && osal.done_exists('nix_install') {
		console.print_header('Nix already installed')
		return
	}

	cmd:="sh <(curl -L https://nixos.org/nix/install) --daemon"
	osal.execute_interactive(cmd)!


	// osal.done_set('nix_install', 'OK')!
}
