module osal

// update the package list
pub fn package_refresh() ! {
	platform_ := platform()
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
pub fn package_install(name string) ! {
	platform_ := platform()
	if platform_ == .osx {
		exec(cmd: 'brew install ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else if platform_ == .ubuntu {
		exec(cmd: 'apt install -y ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else if platform_ == .alpine {
		exec(cmd: 'apk install ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else {
		return error('Only ubuntu, alpine and osx supported for now')
	}
}

// upgrade the us, only implemented for ubuntu right now
pub fn upgrade() ! {
	platform_ := platform()
	if platform_ == .ubuntu {
		upgrade_cmds := '
			sudo killall apt apt-get
			rm -f /var/lib/apt/lists/lock
			rm -f /var/cache/apt/archives/lock
			rm -f /var/lib/dpkg/lock*		
			export TERM=xterm
			export DEBIAN_FRONTEND=noninteractive
			dpkg --configure -a
			set -ex
			apt update
			apt upgrade  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			apt autoremove  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			apt install apt-transport-https ca-certificates curl software-properties-common  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			'

		exec(
			cmd: upgrade_cmds
			retry: 5
			description: 'upgrade operating system packages'
		)!
	} else {
		return error('Only ubuntu is supported for now')
	}
}
