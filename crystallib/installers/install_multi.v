module installers

import freeflowuniverse.crystallib.installers.base
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
import freeflowuniverse.crystallib.installers.lang.nodejs
import freeflowuniverse.crystallib.installers.lang.python
import freeflowuniverse.crystallib.installers.web.caddy
import freeflowuniverse.crystallib.installers.hero.heroweb
import freeflowuniverse.crystallib.installers.hero.herodev
import freeflowuniverse.crystallib.installers.sysadmintools.dagu

@[params]
pub struct InstallArgs {
pub mut:
	names     string
	reset     bool
	uninstall bool
	gitpull   bool
	gitreset  bool
	start bool
}

pub fn names(args_ InstallArgs) []string {
	names := '
		base
		caddy
		chrome
		crystal
		dagu
		develop
		golang
		hero
		herodev
		heroweb
		lima
		mycelium
		nodejs
		podman
		rust
		vlang
		vscode
		'
	mut ns := texttools.to_array(names)
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
			'base' {
				base.install(reset: args.reset)!
			}
			'develop' {
				base.install(reset: args.reset, develop: true)!
			}
			'rust' {
				rust.install(reset: args.reset)!
			}
			'golang' {
				golang.install(reset: args.reset)!
			}
			'vlang' {
				vlang.install(reset: args.reset)!
			}
			'crystal' {
				crystallib.install(
					reset: args.reset
					git_pull: args.gitpull
					git_reset: args.gitreset
				)!
			}
			'hero' {
				crystallib.hero_install(reset: args.reset)!
			}
			'caddy' {
				caddy.install(reset: args.reset)!
				caddy.configure_examples()!
			}
			'chrome' {
				chrome.install(reset: args.reset, uninstall: args.uninstall)!
			}
			'mycelium' {
				mycelium.install(reset: args.reset)!
				mycelium.start()!
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
			'nodejs' {
				nodejs.install(reset: args.reset)!
			}
			'python' {
				python.install()!
			}
			'herodev' {
				herodev.install()!
			}
			'heroweb' {
				heroweb.install()!
			}
			'dagu' {
				dagu.install()!
			}
			else {
				return error('cannot find installer for: ${item}')
			}
		}
	}
}
