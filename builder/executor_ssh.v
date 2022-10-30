module builder

import os
import rand
import freeflowuniverse.crystallib.process
import ipaddress

[heap]
struct ExecutorSSH {
mut:
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
			executor.ipaddr.port = 22
		}
		// TODO: need to call code from SSHAGENT do not reimplement here
		process.execute_job(cmd: 'pgrep -x ssh-agent || eval `ssh-agent -s`') or {
			return error('Could not start ssh-agent, error was: $err')
		}
		if executor.sshkey != '' {
			process.execute_job(cmd: 'ssh-add $executor.sshkey')!
		}
		mut addr := executor.ipaddr.addr
		if addr == '' {
			addr = 'localhost'
		}
		// TODO: doesn't work with ipv6 after working with ipv4
		cmd := "sh -c 'ssh-keyscan -H $executor.ipaddr.addr -p $executor.ipaddr.port -t ecdsa-sha2-nistp256 2>/dev/null >> ~/.ssh/known_hosts'"
		process.execute_silent(cmd) or { return error('cannot add the ssh keys to known hosts') }
		executor.initialized = true
	}
}

fn (mut executor ExecutorSSH) debug_on() {
	executor.debug = true
}

fn (mut executor ExecutorSSH) debug_off() {
	executor.debug = false
}

fn (mut executor ExecutorSSH) exec(cmd string) !string {
	cmd2 := 'ssh $executor.user@$executor.ipaddr.addr -p $executor.ipaddr.port "$cmd"'
	if executor.debug {
		println(' .. execute $executor.ipaddr.addr: $cmd')
	}
	res := process.execute_job(cmd: cmd2, stdout: true, stdout_log: true)!
	return res.output
}

fn (mut executor ExecutorSSH) exec_silent(cmd string) !string {
	mut stdout := false
	if executor.debug {
		stdout = true
		println(' .. execute $executor.ipaddr.addr: $cmd')
	}
	cmd2 := 'ssh $executor.user@$executor.ipaddr.addr -p $executor.ipaddr.port "$cmd"'
	res := process.execute_job(cmd: cmd2, stdout: stdout)!
	return res.output
}

fn (mut executor ExecutorSSH) file_write(path string, text string) ! {
	if executor.debug {
		println(' - $executor.ipaddr.addr file write: $path')
	}
	local_path := '/tmp/$rand.uuid_v4()'
	os.write_file(local_path, text)!
	executor.upload(local_path, path)!
	os.rm(local_path)!
}

fn (mut executor ExecutorSSH) file_read(path string) !string {
	if executor.debug {
		println(' - $executor.ipaddr.addr file read: $path')
	}
	local_path := '/tmp/$rand.uuid_v4()'
	executor.download(path, local_path)!
	r := os.read_file(local_path)!
	os.rm(local_path) or { panic(err) }
	return r
}

fn (mut executor ExecutorSSH) file_exists(path string) bool {
	if executor.debug {
		println(' - $executor.ipaddr.addr file exists: $path')
	}
	output := executor.exec('test -f $path && echo found || echo not found') or { return false }
	if output == 'found' {
		return true
	}
	return false
}

// carefull removes everything
fn (mut executor ExecutorSSH) delete(path string) ! {
	if executor.debug {
		println(' - $executor.ipaddr.addr file delete: $path')
	}
	executor.exec('rm -rf $path') or { panic(err) }
}

// upload from local FS to executor FS
fn (mut executor ExecutorSSH) download(source string, dest string) ! {
	port := executor.ipaddr.port
	if executor.debug {
		println(' - $executor.ipaddr.addr file download: $source')
	}
	// detection about ipv4/ipv6 for use [] or not
	mut cmd_ipaddr := '$executor.ipaddr.addr'
	if executor.ipaddr.cat == .ipv6 {
		cmd_ipaddr = '[$executor.ipaddr.addr]'
	}
	mut job := process.Job{}
	job = process.execute_job(
		cmd: 'rsync -avHPe "ssh -p$port" $executor.user@$cmd_ipaddr:$source $dest'
		die: false
	)!
	if job.exit_code > 0 {
		if job.output.contains('rsync: command not found') {
			executor.exec('apt update && apt install rsync -y') or {
				// TODO, not good enough because we need to check which platform
				return error('could install rsync, was maybe not ubuntu.\n$executor')
			}
			job = process.execute_job(
				cmd: 'rsync -avHPe "ssh -p$port" $executor.user@$cmd_ipaddr:$source $dest'
				die: false
			)!
		}
	}
	if job.exit_code > 0 {
		return error('could rsync.\n$job')
	}
}

// download from executor FS to local FS
fn (mut executor ExecutorSSH) upload(source string, dest string) ! {
	port := executor.ipaddr.port
	if executor.debug {
		println(' - $executor.ipaddr.addr file upload: $source -> $dest')
	}
	// detection about ipv4/ipv6 for use [] or not
	mut cmd_ipaddr := '$executor.ipaddr.addr'
	if executor.ipaddr.cat == .ipv6 {
		cmd_ipaddr = '[$executor.ipaddr.addr]'
	}
	process.execute_job(
		cmd: 'rsync -avHPe "ssh -p$port" $source -e ssh $executor.user@$cmd_ipaddr:$dest'
	) or {panic(@FN + ": Cannot execute job")}
}

// get environment variables from the executor
fn (mut executor ExecutorSSH) environ_get() !map[string]string {
	env := executor.exec('env') or { return error('can not get environment') }

	if executor.debug {
		println(' - $executor.ipaddr.addr env get')
	}

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
fn (mut executor ExecutorSSH) info() map[string]string {
	return {
		'category':  'ssh'
		'sshkey':    executor.sshkey
		'user':      executor.user
		'ipaddress': executor.ipaddr.addr
		'port':      '$executor.ipaddr.port'
	}
}

// ssh shell on the node default ssh port, or any custom port that may be
// forwarding ssh traffic to certain container

fn (mut executor ExecutorSSH) shell(cmd string) ! {
	mut p := '$executor.ipaddr.port'
	if cmd.len > 0 {
		panic('TODO IMPLEMENT SHELL EXEC OVER SSH')
	}
	os.execvp('ssh', ['$executor.user@$executor.ipaddr.addr', '-p $p'])!
}

fn (mut executor ExecutorSSH) list(path string) ![]string {
	if !executor.dir_exists(path) {
		panic('Dir Not found')
	}
	mut res := []string{}
	output := executor.exec('ls $path')!
	for line in output.split('\n') {
		res << line
	}
	return res
}

fn (mut executor ExecutorSSH) dir_exists(path string) bool {
	output := executor.exec('test -d $path && echo found || echo not found') or { return false }
	if output.trim_space() == 'found' {
		return true
	}
	return false
}
