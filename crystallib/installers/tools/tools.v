module tools

// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.vscode
import freeflowuniverse.crystallib.installers.chrome
import freeflowuniverse.crystallib.installers.podman
import freeflowuniverse.crystallib.installers.lima

@[params]
pub struct InstallArgs {
pub mut:
	names     string
	reset     bool
	uninstall bool
}

pub fn install_multi(args_ InstallArgs) ! {
	mut args := args_
	mut items := []string{}
	for item in args.names.split(',').map(it.trim_space()) {
		if item !in items {
			items << item
		}
	}
	for item in items {
		match item {
			'vscode' {
				vscode.install(reset: args.reset)!
			}
			'chrome' {
				chrome.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'podman' {
				podman.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'lima' {
				lima.install(reset: args.reset, uninstall: args.uninstall)!
			}
			else {
				return error('cannot find installer for: ${item}')
			}
		}
	}
}
