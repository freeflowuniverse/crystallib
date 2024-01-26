module osal

import time
import os
import math

pub enum PMState {
	init
	ok
	old
}

@[heap]
pub struct ProcessMap {
pub mut:
	processes []ProcessInfo
	lastscan  time.Time
	state     PMState
}

@[heap]
pub struct ProcessInfo {
pub mut:
	cpu_perc f32
	mem_perc f32
	cmd      string
	pid      int
	ppid     int // parentpid
	// resident memory
	rss int
}

// make sure to use new first, so that the connection has been initted
// then you can get it everywhere
pub fn processmap_get() !ProcessMap {
	mut pm := ProcessMap{}
	pm.scan()!
	return pm
}

// get process info from 1 specific process
// returns
//```
// pub struct ProcessInfo {
// pub mut:
// 	cpu_perc	f32
// 	mem_perc	f32
// 	cmd 		string
// 	pid 		int
// 	ppid 		int
// 	//resident memory
// 	rss			int
// }
//```
pub fn procesinfo_get(pid int) !ProcessInfo {
	mut pm := processmap_get()!
	for pi in pm.processes {
		if pi.pid == pid {
			return pi
		}
	}
	return error('Cannot find process with pid: ${pid}, to get process info from.')
}

// return the process and its children
pub fn processinfo_with_children(pid int) !ProcessMap {
	mut pi := procesinfo_get(pid)!
	mut res := processinfo_children(pid)!
	res.processes << pi
	return res
}

// get all children of 1 process
pub fn processinfo_children(pid int) !ProcessMap {
	mut pm := processmap_get()!
	mut res := []ProcessInfo{}
	pm.children_(mut res, pid)!
	return ProcessMap{
		processes: res
		lastscan: pm.lastscan
		state: pm.state
	}
}

// kill process and all the ones underneith
pub fn process_kill_recursive(pid int) ! {
	pm := processinfo_with_children(pid)!
	for p in pm.processes {
		os.execute('kill -9 ${p.pid}')
	}
}

fn (pm ProcessMap) children_(mut result []ProcessInfo, pid int) ! {
	// println("children: $pid")
	for p in pm.processes {
		if p.ppid == pid {
			// println("found parent: ${p}")
			if result.filter(it.pid == p.pid).len == 0 {
				result << p
				pm.children_(mut result, p.pid)! // find children of the one we found
			}
		}
	}
}

pub fn (mut p ProcessInfo) str() string {
	x := math.min(60, p.cmd.len)
	subst := p.cmd.substr(0, x)
	return 'pid:${p.pid:-7} parent:${p.ppid:-7} cmd:${subst}'
}

fn (mut pm ProcessMap) str() string {
	mut out := ''
	for p in pm.processes {
		out += '${p}\n'
	}
	return out
}

fn (mut pm ProcessMap) scan() ! {
	now := time.now().unix_time()
	// only scan if we didn't do in last 5 seconds
	if pm.lastscan.unix_time() > now - 5 {
		// means scan is ok
		if pm.state == PMState.ok {
			return
		}
	}

	cmd := 'ps ax -o pid,ppid,stat,%cpu,%mem,rss,command'
	res := os.execute(cmd)

	if res.exit_code > 0 {
		return error('Cannot get process info \n${cmd}')
	}

	pm.processes = []ProcessInfo{}

	// println("DID SCAN")
	for line in res.output.split_into_lines() {
		if !line.contains('PPID') {
			mut fields := line.fields()
			if fields.len < 6 {
				// println(res)
				// println("SSS")
				// println(line)
				// panic("ss")
				continue
			}
			mut pi := ProcessInfo{}
			pi.pid = fields[0].int()
			pi.ppid = fields[1].int()
			pi.cpu_perc = fields[3].f32()
			pi.mem_perc = fields[4].f32()
			pi.rss = fields[5].int()
			fields.delete_many(0, 6)
			pi.cmd = fields.join(' ')
			// println(pi.cmd)
			pm.processes << pi
		}
	}

	pm.lastscan = time.now()
	pm.state = PMState.ok

	// println(pm)
}

pub fn whoami() !string {
	res := os.execute('whoami')
	if res.exit_code > 0 {
		return error('Could not do whoami\n${res}')
	}
	return res.output.trim_space()
}
