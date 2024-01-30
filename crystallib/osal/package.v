module osal

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools

// update the package list
pub fn package_refresh() ! {
	platform_ := platform()

	if cmd_exists('nix-env') {
		// means nix package manager is installed
		// nothing to do
		return
	}

	if platform_ == .ubuntu {
		exec(cmd: 'apt-get update') or {
			return error('Could not update packages list\nerror:\n${err}')
		}
	} else if platform_ == .osx {
		exec(cmd: 'brew update') or {
			return error('Could not update packages list\nerror:\n${err}')
		}
	} else if platform_ == .alpine {
		exec(cmd: 'apk update') or {
			return error('Could not update packages list\nerror:\n${err}')
		}
	}
	return error('Only ubuntu, alpine and osx is supported for now')
}

// install a package will use right commands per platform
pub fn package_install(name_ string) ! {
	names := texttools.to_array(name_)

	// if cmd_exists('nix-env') {
	// 	// means nix package manager is installed
	// 	names_list := names.join(' ')
	// 	console.print_header('package install: ${names_list}')
	// 	exec(cmd: 'nix-env --install ${names_list}') or {
	// 		return error('could not install package using nix:${names_list}\nerror:\n${err}')
	// 	}
	// 	return
	// }

	for name in names {
		console.print_header('package install: ${name}')

		platform_ := platform()
		if platform_ == .osx {
			exec(cmd: 'brew install ${name}') or {
				return error('could not install package:${name}\nerror:\n${err}')
			}
		} else if platform_ == .ubuntu {
			exec(
				cmd: '
				export TERM=xterm
				export DEBIAN_FRONTEND=noninteractive
				apt install -y ${name}  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --allow-downgrades --allow-remove-essential --allow-change-held-packages
				'
			) or { return error('could not install package:${name}\nerror:\n${err}') }
		} else if platform_ == .alpine {
			exec(cmd: 'apk add ${name}') or {
				return error('could not install package:${name}\nerror:\n${err}')
			}
		} else if platform_ == .arch {
			exec(cmd: 'pacman --noconfirm -Su ${name}') or {
				return error('could not install package:${name}\nerror:\n${err}')
			}
		} else {
			return error('Only ubuntu, alpine and osx supported for now')
		}
	}
}
