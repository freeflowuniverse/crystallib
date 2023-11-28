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
	if name.contains(',') {
		for n in name.split(',') {
			package_install(n.trim_space())!
		}
		return
	}
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
		exec(cmd: 'apk install ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else {
		return error('Only ubuntu, alpine and osx supported for now')
	}
}

// upgrade the OS, only implemented for ubuntu right now
pub fn upgrade() ! {
	platform_ := platform()
	if platform_ == .ubuntu {
		upgrade_cmds := '
			set +ex
			sudo killall apt apt-get > /dev/null 2>&1
			set -ex
			rm -f /var/lib/apt/lists/lock
			rm -f /var/cache/apt/archives/lock
			rm -f /var/lib/dpkg/lock*		
			dpkg --configure -a
			apt update
			apt upgrade  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			apt autoremove  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			apt install apt-transport-https ca-certificates curl software-properties-common  -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --force-yes
			'

		exec(
			cmd: upgrade_cmds
			retry: 2
			description: 'upgrade operating system packages'
		)!
	} else {
		return error('Only ubuntu is supported for now')
	}
}
