module pathlib

import os

[params]
pub struct RsyncArgs {
pub mut:
	source         string
	dest           string
	ipaddr_src     string // e.g. root@192.168.5.5:33 (can be without root@ or :port)
	ipaddr_dst     string
	delete         bool     // do we want to delete the destination
	ignore         []string // arguments to ignore e.g. ['*.pyc','*.bak']
	ignore_default bool = true // if set will ignore a common set
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
	cmd := rsync_cmd(args)!
	$if debug {println(" - rsync command:\n$cmd")}
	// os.execvp('/bin/bash', ["-c '${cmd}'"])!
	r := os.execute(cmd)
	if r.exit_code > 0 {
		return error('Could not execute the rsync.\n${r}')
	}
}

// return the cmd with all rsync arguments .
// see rsync for usage of args
pub fn rsync_cmd(args_ RsyncArgs) !string {
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
	mut dest_path := get(args.dest)
	if !src_path.is_file() {
		args.dest = args.dest + '/'
	}

	if args.ipaddr_src.len > 0 && args.ipaddr_dst.len == 0 {
		sshpart, addrpart = rsync_ipaddr_format(args.ipaddr_src)
		cmd = 'rsync  ${options} ${delete} ${exclude} ${sshpart} ${addrpart}:${args.source} ${args.dest}'
	} else if args.ipaddr_dst.len > 0 && args.ipaddr_src.len == 0 {
		sshpart, addrpart = rsync_ipaddr_format(args.ipaddr_dst)
		cmd = 'rsync  ${options} ${delete} ${exclude} ${sshpart} ${args.source} ${addrpart}:${args.dest}'
	} else if args.ipaddr_dst.len > 0 && args.ipaddr_src.len > 0 {
		return error('cannot have source and dest as ssh')
	} else {
		cmd = 'rsync ${options} ${delete} ${exclude} ${args.source} ${args.dest}'
	}
	return cmd
}

fn rsync_ipaddr_format(ipaddr_ string) (string, string) {
	mut ipaddr := ipaddr_
	mut user := 'root'
	mut port := '22'
	if ipaddr.contains('@') {
		user, ipaddr = ipaddr.split_once('@') or { panic('bug') }
	}
	println("- '${ipaddr_}' ${user} ${ipaddr}")
	if ipaddr.contains(':') {
		ipaddr, port = ipaddr.rsplit_once(':') or { panic('bug') }
	}
	if ipaddr.len == 0 {
		panic('ip addr cannot be empty')
	}
	return '-e \'ssh -p ${port}\'', '${user}@${ipaddr}'
}
