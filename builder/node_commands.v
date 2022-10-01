module builder

import freeflowuniverse.crystallib.texttools
import crypto.md5
import time
import os

// check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {
	_ := node.exec('which $cmd') or { return false }
	return true
}

pub struct NodeExecCmd {
pub mut:
	cmd              string
	period           int // period in which we check when this was done last, if 0 then period is indefinite
	reset            bool = true
	remove_installer bool = true // delete the installer
	description      string
	stdout           bool = true
	checkkey         string // if used will use this one in stead of hash of cmd, to check if was executed already
	tmpdir           string
}

// return the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn (mut node Node) ipaddr_pub_get() ?string {
	if !node.done_exists('ipaddr') {
		cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
		res := node.exec(cmd)?
		node.done_set('ipaddr', res.trim('\n').trim(' \n'))?
	}
	mut ipaddr := node.done_get('ipaddr')?
	return ipaddr.trim('\n').trim(' \n')
}

// cmd: cmd to execute
// period in sec, e.g. if 3600, means will only execute this if not done yet within the hour
//
// ARGS:
//```
// struct NodeExecCmd{
// 	cmd string
// 	period int //period in which we check when this was done last, if 0 then period is indefinite
// 	reset bool = true
// 	description string
//	checkkey string //if used will use this one in stead of hash of cmd, to check if was executed already
// }
// ```
pub fn (mut node Node) exec_cmd(args NodeExecCmd) ? {
	// println(args)
	mut cmd := args.cmd
	mut now_epoch := time.now().unix_time()
	mut now_str := now_epoch.str()
	if cmd.contains('\n') {
		cmd = texttools.dedent(cmd)
	}

	mut hhash := ''
	if args.checkkey.len > 0 {
		hhash = args.checkkey
	} else {
		hhash = md5.hexhash(cmd)
	}
	mut description := args.description
	if description == '' {
		description = cmd
		if description.contains('\n') {
			description = '\n$description\n'
		}
	}
	if !args.reset && node.done_exists('exec_$hhash') {
		if args.period == 0 {
			println('   - exec cmd:$description on $node.name: was already done, period indefinite.')
			return
		}
		exec_last_time := node.done_get_str('exec_$hhash').int()
		assert exec_last_time > 10000
		// println(args)
		// println("   - check exec cmd:$cmd on $node.name: time:$exec_last_time")
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			println('   - exec cmd:$description on $node.name: was already done, period $hours h')
			return
		}
	}

	if args.reset && args.tmpdir.len > 2 {
		node.delete(args.tmpdir)?
	}

	mut r_path := '/tmp/${hhash}.sh'
	if args.tmpdir.len > 2 {
		r_path = '$args.tmpdir/installer.sh'
		node.exec_silent('mkdir -p $args.tmpdir')?
	}
	node.file_write(r_path, cmd)?
	if args.tmpdir.len > 2 {
		cmd = "mkdir -p $args.tmpdir && cd $args.tmpdir && export TMPDIR='$args.tmpdir' && bash $r_path"
	} else {
		cmd = 'cd /tmp && bash $r_path'
	}

	// println("   - exec cmd:$cmd on $node.name")
	node.exec(cmd) or { return error(err.msg() + '\noriginal cmd:\n$args.cmd') }

	if args.remove_installer {
		if args.tmpdir.len > 2 {
			node.delete(args.tmpdir)?
		} else {
			node.delete(r_path)?
		}
	}
	node.done_set('exec_$hhash', now_str)?
}

// check if we can execute and there is not errorcode
pub fn (mut node Node) exec_ok(cmd string) bool {
	// TODO: need to put in support for multiline text files
	if cmd.contains('\n') {
		panic('cannot have \\n in cmd. $cmd, use exec function instead')
	}
	node.exec_silent(cmd) or {
		// see if it executes ok, if cmd not found is false
		return false
	}
	// println(e)
	return true
}

fn (mut node Node) platform_load() {
	println(' - platform load')
	if node.platform == PlatformType.unknown {
		if node.cmd_exists('sw_vers') {
			node.platform = PlatformType.osx

			// node execute uname -m ?

			// TODO: does not work for remote !!!
			if os.uname().machine.to_lower() == 'x86_64' {
				node.cputype = CPUType.intel
			} else {
				node.cputype = CPUType.arm
			}
		} else if node.cmd_exists('apt-get') {
			node.platform = PlatformType.ubuntu
			node.package_refresh() or {}
		} else if node.cmd_exists('apk') {
			node.platform = PlatformType.alpine
		} else {
			panic('only ubuntu, alpine and osx supported for now')
		}
	}
}

pub fn (mut node Node) package_refresh() ? {
	if node.platform == PlatformType.ubuntu {
		node.exec('apt-get update') or {
			return error('could not update packages list\nerror:\n$err')
		}
	}
}

pub fn (mut node Node) package_install(package Package) ? {
	name := package.name
	if node.platform == PlatformType.osx {
		node.exec('brew install $name') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else if node.platform == PlatformType.ubuntu {
		node.exec('apt-get install -y $name') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else if node.platform == PlatformType.alpine {
		node.exec('apk install $name') or {
			return error('could not install package:$package.name\nerror:\n$err')
		}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}

fn (mut node Node) upgrade() ? {
	if node.platform == PlatformType.ubuntu {
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

		node.exec_cmd(
			cmd: upgrade_cmds
			period: 48 * 3600
			reset: false
			description: 'upgrade operating system packages'
		)?
	}
}