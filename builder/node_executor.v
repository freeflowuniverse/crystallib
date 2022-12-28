module builder

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

// 	download(source string, dest string) !
// 	upload(source string, dest string) !
// 	environ_get() !map[string]string
// 	info() map[string]string
// 	shell(cmd string) !

pub fn (mut node Node) download(source string, dest string) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.download(source, dest)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.download(source, dest)
	}
	panic('did not find right executor')
}

pub fn (mut node Node) upload(source string, dest string) ! {
	if mut node.executor is ExecutorLocal {
		return node.executor.upload(source, dest)
	} else if mut node.executor is ExecutorSSH {
		return node.executor.upload(source, dest)
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
