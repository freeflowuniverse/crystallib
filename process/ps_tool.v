module process

import time

pub enum PMState {
	init
	ok
	old
}


[heap]
pub struct ProcessMap {
pub mut:
	processes 	[]&ProcessInfo
	lastscan	time.Time
	state		PMState
}

[heap]
pub struct ProcessInfo {
pub mut:
	cpu_perc	f32
	mem_perc	f32
	cmd 		string
	pid 		int
	ppid 		int
	//resident memory
	rss			int
}


//needed to get singleton
fn init3() ProcessMap {
	mut f := process.ProcessMap{}	
	return f
}


//singleton creation
const processmap = init3()

//make sure to use new first, so that the connection has been initted
//then you can get it everywhere
pub fn processmap_get() ?&ProcessMap {
	mut pm := process.processmap
	pm.scan()?
	return &pm
}


//get process info from 1 specific process
//returns
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
pub fn procesinfo_get(pid int) ?&ProcessInfo {
	mut pm := processmap_get()?
	for pi in pm.processes{
		if pi.pid == pid{
			return pi
		}
	}
	return error("Cannot find process with pid: $pid, to get process info from.")

}


pub fn (mut pm ProcessMap) scan()? {

	now := time.now().unix_time()
	//only scan if we didn't do in last 5 seconds
	if pm.lastscan.unix_time() > now - 5 
	{
		//means scan is ok
		if pm.state == PMState.ok { return }
	}

	cmd := "ps ax -o pid,ppid,stat,%cpu,%mem,rss,command"
	res := execute_silent(cmd) or {
		return error("Cannot get process info \n$cmd\n$err")
	}

	pm.processes = []&ProcessInfo{}

	// println("DID SCAN")
	for line in res.split_into_lines() {
		if ! line.contains('PPID') {
			mut fields:=line.fields()
			if fields.len<6{
				// println(res)
				// println("SSS")
				// println(line)
				// panic("ss")
				continue
			}
			mut pi := ProcessInfo{}
			pi.ppid=fields[0].int()
			pi.pid=fields[1].int()
			pi.cpu_perc=fields[3].f32()
			pi.mem_perc=fields[4].f32()
			pi.rss=fields[5].int()
			fields.delete_many(0,6)			
			pi.cmd = fields.join(" ")
			// println(pi.cmd)
			pm.processes << &pi
		}
	}

	pm.lastscan = time.now()
	pm.state = PMState.ok

	// println(pm)

}
