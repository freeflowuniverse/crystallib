module pathlib

import os

@[params]
pub struct RsyncArgs {
pub mut:
	source         string
	dest           string
	ipaddr_src     string // e.g. root@192.168.5.5:33 (can be without root@ or :port)
	ipaddr_dst     string
	delete         bool     // do we want to delete the destination
	ignore         []string // arguments to ignore e.g. ['*.pyc','*.bak']
	ignore_default bool = true // if set will ignore a common set
	debug bool = true
}

// flexible tool to sync files from to, does even support ssh .
// args: .
// ```
// 	source string
// 	dest string
// 	delete bool //do we want to delete the destination
//  ipaddr_src string //e.g. root@192.168.5.5:33 (can be without root@ or :port)
//  ipaddr_dst string //can only use src or dst, not both
// 	ignore []string //arguments to ignore
//  ignore_default bool = true //if set will ignore a common set
//  stdout bool = true
// ```
// .
pub fn rsync(args_ RsyncArgs) ! {
	mut args := args_
	if args.ipaddr_src.len == 0 {
		get(args.source)
	}
	cmdoptions := rsync_cmd_options(args)!
	$if debug {
		println(' - rsync command:\n${cmdoptions}')
	}
	r  := os.execute("which rsync")
	if r.exit_code > 0 {
		return error('Could not find the rsync command, please install.')
	}
	rsyncpath:=r.output.trim_space()
	// execute(cmd:cmd,stdout:args.debug)!
	cmdoptions2:=cmdoptions.replace("  "," ").split(" ")
	os.execvp(rsyncpath, cmdoptions2)!

}

// return the cmd with all rsync arguments .
// see rsync for usage of args
pub fn rsync_cmd_options(args_ RsyncArgs) !string {
	mut args := args_
	mut cmd := ''

	// normalize
	args.source = os.norm_path(args.source)
	args.dest = os.norm_path(args.dest)

	mut delete := ''
	if args.delete {
		delete = '--delete'
	}
	options := '-avz --no-perms'
	mut sshpart := ''
	mut addrpart := ''

	mut exclude := ''
	if args.ignore_default {
		defaultset := ['*.pyc', '*.bak', '*dSYM']
		for item in defaultset {
			if item !in args.ignore {
				args.ignore << item
			}
		}
	}
	for excl in args.ignore {
		exclude += " --exclude='${excl}'"
	}

	args.source = args.source.trim_right('/ ')
	args.dest = args.dest.trim_right('/ ')

	// if file is being copied to file dest, trailing slash shouldn't be there
	mut src_path := get(args.source)
	if !src_path.is_file() {
		args.source = args.source + '/'
	}

	if !src_path.is_file() {
		args.dest = args.dest + '/'
	}

	if args.ipaddr_src.len > 0 && args.ipaddr_dst.len == 0 {
		sshpart, addrpart = rsync_ipaddr_format(ipaddr:args.ipaddr_src)
		cmd = '${options} ${delete} ${exclude} ${sshpart} ${addrpart}:${args.source} ${args.dest}'
	} else if args.ipaddr_dst.len > 0 && args.ipaddr_src.len == 0 {
		sshpart, addrpart = rsync_ipaddr_format(ipaddr:args.ipaddr_dst)
		cmd = '${options} ${delete} ${exclude} ${sshpart} ${args.source} ${addrpart}:${args.dest}'
	} else if args.ipaddr_dst.len > 0 && args.ipaddr_src.len > 0 {
		return error('cannot have source and dest as ssh')
	} else {
		cmd = '${options} ${delete} ${exclude} ${args.source} ${args.dest}'
	}
	return cmd
}

@[params]
struct RsyncFormatArgs{
mut:
	ipaddr string
	user string = 'root'
	port int = 22
}

fn rsync_ipaddr_format(args_ RsyncFormatArgs) (string,string) {
	mut args:=args_
	if args.ipaddr.contains('@') {
		args.user, args.ipaddr = args.ipaddr.split_once('@') or { panic('bug') }
	}
	if args.ipaddr.contains(':') {
		mut port:=""
		args.ipaddr, port = args.ipaddr.rsplit_once(':') or { panic('bug') }
		args.port = port.int()
	}
	args.user=args.user.trim_space()
	args.ipaddr=args.ipaddr.trim_space()
	if args.ipaddr.len == 0 {
		panic('ip addr cannot be empty')
	}
	// println("- rsync cmd: ${args.user}@${args.ipaddr}:${args.port}")
	return '-e \'ssh -o StrictHostKeyChecking=no -p ${args.port}\'', '${args.user}@${args.ipaddr}'
}
