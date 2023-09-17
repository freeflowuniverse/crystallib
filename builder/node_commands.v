module builder

import freeflowuniverse.crystallib.texttools
import crypto.md5
import time

// check command exists on the platform, knows how to deal with different platforms
pub fn (mut node Node) cmd_exists(cmd string) bool {
	return node.exec_ok('which ${cmd}')
}

pub struct NodeExecCmd {
pub mut:
	cmd                string
	period             int  // period in which we check when this was done last, if 0 then period is indefinite
	reset              bool = true // means do again or not
	remove_installer   bool = true // delete the installer
	description        string
	stdout             bool = true
	checkkey           string // if used will use this one in stead of hash of cmd, to check if was executed already
	tmpdir             string
	ignore_error_codes []int
}

// return the ipaddress as known on the public side
// is using resolver4.opendns.com
pub fn (mut node Node) ipaddr_pub_get() !string {
	if !node.done_exists('ipaddr') {
		cmd := 'dig @resolver4.opendns.com myip.opendns.com +short'
		res := node.exec(cmd)!
		node.done_set('ipaddr', res.trim('\n').trim(' \n'))!
	}
	mut ipaddr := node.done_get('ipaddr') or { return 'Error: ipaddr is none' }
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
pub fn (mut node Node) exec_cmd(args_ NodeExecCmd) !string {
	// println(args)
	mut args := args_
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
			description = '\n${description}\n'
		}
	}
	if !args.reset && node.done_exists('exec_${hhash}') {
		if args.period == 0 {
			println('   - exec cmd:${description} on ${node.name}: was already done, period indefinite.')
			return node.done_get('exec_${hhash}') or { '' }
		}
		nodedone := node.done_get_str('exec_${hhash}')
		splitted := nodedone.split('|')
		if splitted.len != 2 {
			panic("Cannot return from done on exec needs to have |, now \n'${nodedone}' ")
		}
		exec_last_time := splitted[0].int()
		lastoutput := splitted[1]
		assert exec_last_time > 10000
		// println(args)
		// println("   - check exec cmd:$cmd on $node.name: time:$exec_last_time")
		if exec_last_time > now_epoch - args.period {
			hours := args.period / 3600
			println('   - exec cmd:${description} on ${node.name}: was already done, period ${hours} h')
			return lastoutput
		}
	}

	if args.tmpdir.len == 0 {
		if 'TMPDIR' !in node.environment {
			args.tmpdir = '/tmp'
		} else {
			args.tmpdir = node.environment['TMPDIR']
		}
	}
	r_path := '${args.tmpdir}/installer.sh'
	osal.file_write(r_path, cmd)!
	cmd = "mkdir -p ${args.tmpdir} && cd ${args.tmpdir} && export TMPDIR='${args.tmpdir}' && bash ${r_path}"
	if args.remove_installer {
		cmd += ' && rm -f ${r_path}'
	}
	// println("   - exec cmd:$cmd on $node.name")
	res := node.exec(cmd) or { return error(err.msg() + '\noriginal cmd:\n${args.cmd}') }

	node.done_set('exec_${hhash}', '${now_str}|${res}')!
	return res
}

// check if we can execute and there is not errorcode
pub fn (mut node Node) exec_ok(cmd string) bool {
	// TODO: need to put in support for multiline text files
	if cmd.contains('\n') {
		panic('cannot have \\n in cmd. ${cmd}, use exec function instead')
	}
	node.exec_silent(cmd) or {
		// see if it executes ok, if cmd not found is false
		return false
	}
	// println(e)
	return true
}

fn (mut node Node) platform_load() ! {
	// TODO: should rewrite this with one bash script, which gets the required info & returns e.g. env, platform, ... is much faster
	println(' - platform load')
	mut cputype := node.exec_silent('uname -m')!
	cputype = cputype.to_lower().trim_space()
	if cputype == 'x86_64' {
		node.cputype = CPUType.intel
	} else if cputype == 'arm64' {
		node.cputype = CPUType.arm
	} else {
		return error("did not find cpu type, implement more types e.g. 32 bit. found: '${cputype}'")
	}

	if node.platform == PlatformType.unknown {
		if node.cmd_exists('sw_vers') {
			node.platform = PlatformType.osx
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

pub fn (mut node Node) package_refresh() ! {
	if node.platform == PlatformType.ubuntu {
		node.exec('apt-get update') or {
			return error('could not update packages list\nerror:\n${err}')
		}
	}
}

pub fn (mut node Node) package_install(package Package) ! {
	name := package.name
	if node.platform == PlatformType.osx {
		node.exec('brew install ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else if node.platform == PlatformType.ubuntu {
		node.exec('apt install -y ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else if node.platform == PlatformType.alpine {
		node.exec('apk install ${name}') or {
			return error('could not install package:${package.name}\nerror:\n${err}')
		}
	} else {
		panic('only ubuntu, alpine and osx supported for now')
	}
}

fn (mut node Node) upgrade() ! {
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
		)!
	}
}
