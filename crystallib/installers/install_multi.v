module installers

// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.develapps.vscode
import freeflowuniverse.crystallib.installers.develapps.chrome
import freeflowuniverse.crystallib.installers.virt.podman
import freeflowuniverse.crystallib.installers.virt.lima
import freeflowuniverse.crystallib.installers.net.mycelium

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
			'chrome' {
				chrome.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'mycelium' {
				mycelium.install(reset: args.reset)!
			}			
			'lima' {
				lima.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'podman' {
				podman.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'vscode' {
				vscode.install(reset: args.reset)!
			}

			else {
				return error('cannot find installer for: ${item}')
			}
		}
	}
}
