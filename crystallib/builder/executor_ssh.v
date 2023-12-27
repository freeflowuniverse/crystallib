module builder

import os
import rand
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.data.ipaddress
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct ExecutorSSH {
pub mut:
	ipaddr      ipaddress.IPAddress
	sshkey      string
	user        string = 'root' // default will be root
	initialized bool
	retry       int = 1 // nr of times something will be retried before failing, need to check also what error is, only things which should be retried need to be done
	debug       bool
}

fn (mut executor ExecutorSSH) init() ! {
	if !executor.initialized {
		if executor.ipaddr.port == 0 {
			return error("port cannot be 0.\n$executor")
		}
		// TODO: need to call code from SSHAGENT do not reimplement here
		osal.exec(cmd: 'pgrep -x ssh-agent || eval `ssh-agent -s`',stdout:false) or {
			return error('Could not start ssh-agent, error was: ${err}')
		}
		if executor.sshkey != '' {
			osal.exec(cmd: 'ssh-add ${executor.sshkey}')!
		}
		mut addr := executor.ipaddr.addr
		if addr == '' {
			addr = 'localhost'
		}
		// TODO: doesn't work with ipv6 after working with ipv4, need better check too, because this slows everything down
		// cmd := "sh -c 'ssh-keyscan -H ${executor.ipaddr.addr} -p ${executor.ipaddr.port} -t ecdsa-sha2-nistp256 2>/dev/null >> ~/.ssh/known_hosts'"
		// osal.execute_silent(cmd) or { return error('cannot add the ssh keys to known hosts') }
		executor.initialized = true
	}
}

pub fn (mut executor ExecutorSSH) debug_on() {
	executor.debug = true
}

pub fn (mut executor ExecutorSSH) debug_off() {
	executor.debug = false
}



pub fn (mut executor ExecutorSSH) exec(args_ ExecArgs) !string {
	mut args:=args_
	if executor.debug {
		console.print_debug('execute ${executor.ipaddr.addr}: ${args.cmd}')
	}
	args.cmd = 'ssh -o StrictHostKeyChecking=no ${executor.user}@${executor.ipaddr.addr} -p ${executor.ipaddr.port} "${args.cmd}"'
	res := osal.exec(cmd: args.cmd, stdout: args.stdout, debug:executor.debug)!
	return res.output.join_lines()
}

pub fn (mut executor ExecutorSSH) file_write(path string, text string) ! {
	if executor.debug {
		console.print_debug('${executor.ipaddr.addr} file write: ${path}')
	}
	local_path := '/tmp/${rand.uuid_v4()}'
	os.write_file(local_path, text)!
	executor.upload(source: local_path, dest: path,stdout:false)!
	os.rm(local_path)!
}

pub fn (mut executor ExecutorSSH) file_read(path string) !string {
	if executor.debug {
		console.print_debug('${executor.ipaddr.addr} file read: ${path}')
	}
	local_path := '/tmp/${rand.uuid_v4()}'
	executor.download(source: path, dest: local_path)!
	r := os.read_file(local_path)!
	os.rm(local_path) or { panic(err) }
	return r
}

pub fn (mut executor ExecutorSSH) file_exists(path string) bool {
	if executor.debug {
		console.print_debug('${executor.ipaddr.addr} file exists: ${path}')
	}
	output := executor.exec(cmd:'test -f ${path} && echo found || echo not found',stdout:false) or { return false }
	if output == 'found' {
		return true
	}
	return false
}

// carefull removes everything
pub fn (mut executor ExecutorSSH) delete(path string) ! {
	if executor.debug {
		console.print_debug('${executor.ipaddr.addr} file delete: ${path}')
	}
	executor.exec(cmd:'rm -rf ${path}',stdout:false) or { panic(err) }
}

// upload from local FS to executor FS
pub fn (mut executor ExecutorSSH) download(args SyncArgs) ! {
	mut rsargs := osal.RsyncArgs{
		source: args.source
		dest: args.dest
		delete: args.delete
		ipaddr_src: '${executor.user}@${executor.ipaddr.addr}:${executor.ipaddr.port}'
		ignore: args.ignore
		ignore_default: args.ignore_default
		stdout: args.stdout
	}
	osal.rsync(rsargs)!
}

// download from executor FS to local FS
pub fn (mut executor ExecutorSSH) upload(args SyncArgs) ! {
	mut rsargs := osal.RsyncArgs{
		source: args.source
		dest: args.dest
		delete: args.delete
		ipaddr_dst: '${executor.user}@${executor.ipaddr.addr}:${executor.ipaddr.port}'
		ignore: args.ignore
		ignore_default: args.ignore_default
		stdout: args.stdout
	}
	osal.rsync(rsargs)!
}

// get environment variables from the executor
pub fn (mut executor ExecutorSSH) environ_get() !map[string]string {
	env := executor.exec(cmd:'env',stdout:false) or { return error('can not get environment') }
	// if executor.debug {
	// 	console.print_header(' ${executor.ipaddr.addr} env get')
	// }

	mut res := map[string]string{}
	if env.contains('\n') {
		for line in env.split('\n') {
			if line.contains('=') {
				splitted := line.split('=')
				key := splitted[0].trim(' ')
				val := splitted[1].trim(' ')
				res[key] = val
			}
		}
	}
	return res
}

/*
Executor info or meta data
accessing type Executor won't allow to access the
fields of the struct, so this is workaround
*/
pub fn (mut executor ExecutorSSH) info() map[string]string {
	return {
		'category':  'ssh'
		'sshkey':    executor.sshkey
		'user':      executor.user
		'ipaddress': executor.ipaddr.addr
		'port':      '${executor.ipaddr.port}'
	}
}

// ssh shell on the node default ssh port, or any custom port that may be
// forwarding ssh traffic to certain container

pub fn (mut executor ExecutorSSH) shell(cmd string) ! {
	mut p := '${executor.ipaddr.port}'
	if cmd.len > 0 {
		panic('TODO IMPLEMENT SHELL EXEC OVER SSH')
	}
	os.execvp('ssh', ['-o StrictHostKeyChecking=no','${executor.user}@${executor.ipaddr.addr}', '-p ${p}'])!
}

pub fn (mut executor ExecutorSSH) list(path string) ![]string {
	if !executor.dir_exists(path) {
		panic('Dir Not found')
	}
	mut res := []string{}
	output := executor.exec(cmd:'ls ${path}',stdout:false)!
	for line in output.split('\n') {
		res << line
	}
	return res
}

pub fn (mut executor ExecutorSSH) dir_exists(path string) bool {
	output := executor.exec(cmd:'test -d ${path} && echo found || echo not found',stdout:false) or { return false }
	if output.trim_space() == 'found' {
		return true
	}
	return false
}
