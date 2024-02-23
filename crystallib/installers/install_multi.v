module installers

// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.develapps.vscode
import freeflowuniverse.crystallib.installers.develapps.chrome
import freeflowuniverse.crystallib.installers.virt.podman
import freeflowuniverse.crystallib.installers.virt.lima
import freeflowuniverse.crystallib.installers.net.mycelium
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.installers.lang.golang
import freeflowuniverse.crystallib.installers.lang.vlang
import freeflowuniverse.crystallib.installers.lang.crystallib
import freeflowuniverse.crystallib.installers.web.caddy

@[params]
pub struct InstallArgs {
pub mut:
	names     string
	reset     bool
	uninstall bool
}

pub fn names(args_ InstallArgs) []string {
	names:="
		rust
		golang
		vlang
		hero
		crystal
		caddy
		chrome
		mycelium
		lima
		podman
		vscode
		"
	mut ns:=texttools.to_array(names)
	ns.sort()
	return ns
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
			'rust' {
				rust.install(reset: args.reset)!
			}
			'golang' {
				golang.install(reset: args.reset)!
			}	
			'vlang' {
				vlang.install()!
			}	
			'crystal' {
				crystallib.install(reset:true)!
			}		
			'hero' {
				crystallib.hero_install(reset:true)!
			}		
			'caddy' {
				caddy.install(reset:true)!
				caddy.configure_examples()!
			}															
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
