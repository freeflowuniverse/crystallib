module osal


pub fn (mut o Osal) package_refresh() ! {
	platform := o.platform()
	if platform == .ubuntu {
		o.exec(cmd: 'apt-get update') or { return error('Could not update packages list\nerror:\n${err}') }
	} else if platform == .osx {
		o.exec(cmd: 'brew update') or { return error('Could not update packages list\nerror:\n${err}') }
	} else if platform == .alpine {
		o.exec(cmd: 'apk update') or { return error('Could not update packages list\nerror:\n${err}') }
	}
	return error('Only ubuntu, alpine and osx is supported for now')
}

pub fn (mut o Osal) package_install(name string) ! {
	platform := o.platform()
	if platform == PlatformType.osx {
		o.exec(cmd:'brew install ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else if platform == PlatformType.ubuntu {
		o.exec(cmd:'apt install -y ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else if platform == PlatformType.alpine {
		o.exec(cmd:'apk install ${name}') or {
			return error('could not install package:${name}\nerror:\n${err}')
		}
	} else {
		return error('Only ubuntu, alpine and osx supported for now')
	}
}

pub fn (mut o Osal) upgrade() ! {
	platform := o.platform()
	if platform == PlatformType.ubuntu {
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

		o.exec(
			cmd: upgrade_cmds
			period: 48 * 3600
			reset: false
			description: 'upgrade operating system packages'
		)!
	} else{
		return error('Only ubuntu is supported for now')
	}
}
