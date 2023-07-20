module os

pub fn package_refresh() ! {
	if platform == PlatformType.ubuntu {
		exec('apt-get update') or { return error('could not update packages list\nerror:\n${err}') }
	}
}

pub fn package_install(package Package) ! {
	// get platform
	name := package.name
	if platform == PlatformType.osx {
		exec('brew install ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else if platform == PlatformType.ubuntu {
		exec('apt install -y ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else if platform == PlatformType.alpine {
		exec('apk install ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}

fn upgrade() ! {
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

		exec_cmd(
			cmd: upgrade_cmds
			period: 48 * 3600
			reset: false
			description: 'upgrade operating system packages'
		)!
	}
}
