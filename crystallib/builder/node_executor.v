module builder

import time
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal

// 	exec(cmd string) !string
// 	exec_silent(cmd string) !string
// 	file_write(path string, text string) !
// 	file_read(path string) !string
// 	file_exists(path string) bool
// 	delete(path string) !

pub fn (mut node Node) exec(cmd string) !string {
	if mut node.executor is ExecutorLocal {
		return node.executor.exec(cmd)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.exec(cmd)
	}
	panic('did not find right executor')
}

[params]
pub struct ExecFileArgs {
pub:
	path    string
	cmd     string
	execute bool = true
	dedent  bool = true
}

pub fn (mut node Node) exec_file(args ExecFileArgs) ! {
	if args.path == '' {
		return error('need to specify path')
	}
	if args.cmd == '' {
		return error('need to specify cmd')
	}
	mut cmd2 := args.cmd
	if args.dedent {
		cmd2 = texttools.dedent(cmd2)
	}
	osal.file_write(args.path, cmd2)!
	node.exec_silent('chmod +x ${args.path}')!
	if args.execute {
		node.exec('bash ${args.path}')!
	}
}

[params]
pub struct ExecRetryArgs {
pub:
	cmd          string
	retrymax     int = 10 // how may times maximum to retry
	period_milli int = 100 // sleep in between retry in milliseconds
	timeout      int = 2 // timeout for al the tries together
}

// a cool way to execute something until it succeeds
// params:
//  	cmd     string
//  	retrymax int = 10 		//how may times maximum to retry
//   	period_milli int = 100	//sleep in between retry in milliseconds
// 	    timeout int = 2			//timeout for al the tries together
pub fn (mut node Node) exec_retry(args ExecRetryArgs) !string {
	start_time := time.now().unix_time_milli()
	mut run_time := 0.0
	for true {
		run_time = time.now().unix_time_milli()
		if run_time > start_time + args.timeout * 1000 {
			return error('timeout on exec retry for ${args}')
		}
		println(args.cmd)
		r := node.exec_silent(args.cmd) or { 'error' }
		if r != 'error' {
			return r
		}
		time.sleep(args.period_milli * time.millisecond)
	}
	return error('couldnt execute exec retry for ${args}, got at end')
}

// silently execute a command
pub fn (mut node Node) exec_silent(cmd string) !string {
	if mut node.executor is ExecutorLocal {
		return node.executor.exec_silent(cmd)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.exec_silent(cmd)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) file_write(path string, text string) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.file_write(path, text)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.file_write(path, text)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) file_read(path string) !string {
	if mut node.executor is ExecutorLocal {
		return node.executor.file_read(path)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.file_read(path)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) file_exists(path string) bool {
	if mut node.executor is ExecutorLocal {
		return node.executor.file_exists(path)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.file_exists(path)
	}
	panic('did not find right executor')
}

// checks if given executable exists in node
pub fn (mut node Node) command_exists(cmd string) bool {
	output := node.exec_silent('
		if command -v ${cmd} &> /dev/null
		then
			echo 0
		fi') or {
		panic("can't execute command")
	}
	return output.contains('0')
}

pub fn (mut node Node) delete(path string) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.delete(path)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.delete(path)
	}
	panic('did not find right executor')
}

[params]
pub struct SyncArgs {
pub mut:
	source string
	dest string
	delete bool //do we want to delete the destination
	ipaddr string //e.g. root@192.168.5.5:33 (can be without root@ or :port)
	ignore []string //arguments to ignore e.g. ['*.pyc','*.bak']
	ignore_default bool = true //if set will ignore a common set
	stdout bool = true
}


// download files using rsync (can be ssh or local)
// args: .
// ```
// source string
// dest string
// delete bool //do we want to delete the destination
// ignore []string //arguments to ignore e.g. ['*.pyc','*.bak']
// ignore_default bool = true //if set will ignore a common set
// stdout bool = true
// ```
// .
pub fn (mut node Node) download(args SyncArgs) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.download(args)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.download(args)
	}
	panic('did not find right executor')
}

// upload files using rsync (can be ssh or local)
// args: .
// ```
// source string
// dest string
// delete bool //do we want to delete the destination
// ignore []string //arguments to ignore e.g. ['*.pyc','*.bak']
// ignore_default bool = true //if set will ignore a common set
// stdout bool = true
// ```
// .
pub fn (mut node Node) upload(args SyncArgs) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.upload(args)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.upload(args)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) environ_get() !map[string]string {
	if mut node.executor is ExecutorLocal {
		return node.executor.environ_get()
	} else if mut node.executor is ExecutorSSH {
		return node.executor.environ_get()
	}
	panic('did not find right executor')
}

pub fn (mut node Node) info() map[string]string {
	if mut node.executor is ExecutorLocal {
		return node.executor.info()
	} else if mut node.executor is ExecutorSSH {
		return node.executor.info()
	}
	panic('did not find right executor')
}

pub fn (mut node Node) shell(cmd string) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.shell(cmd)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.shell(cmd)
	}
	panic('did not find right executor')
}

// 	list(path string) ![]string
// 	dir_exists(path string) bool
// 	debug_off()
// 	debug_on()
pub fn (mut node Node) list(path string) ![]string {
	if mut node.executor is ExecutorLocal {
		return node.executor.list(path)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.list(path)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) dir_exists(path string) bool {
	if mut node.executor is ExecutorLocal {
		return node.executor.dir_exists(path)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.dir_exists(path)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) debug_off() {
	if mut node.executor is ExecutorLocal {
		node.executor.debug_off()
	} else if mut node.executor is ExecutorSSH {
		node.executor.debug_off()
	}
	panic('did not find right executor')
}

pub fn (mut node Node) debug_on() {
	if mut node.executor is ExecutorLocal {
		node.executor.debug_on()
	} else if mut node.executor is ExecutorSSH {
		node.executor.debug_on()
	}
	panic('did not find right executor')
}
