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


pub fn (mut pm ProcessMap) scan()? {

	now := time.now().unix_time()
	//only scan if we didn't do in last 5 seconds
	if pm.lastscan.unix_time() > now - 5 
	{
		//means scan is ok
		if pm.state == PMState.ok { return }
	}

	// cmd := "ps ax -o pid,ppid,stat,%cpu,%mem,rss,command"
	// res := execute_silent(cmd) or {
	// 	return error("Cannot get process info \n$cmd\n$err")
	// }
	// println("DID SCAN")
	// for line in res.split_into_lines() {
	// 	if ! line.contains('PPID') {
	// 		mut fields:=line.fields()
	// 		mut pi := ProcessInfo{}
	// 		pi.ppid=fields[0].int()
	// 		// pi.stat=fields[1]
	// 		pi.cpu_perc=fields[2].f32()
	// 		pi.mem_perc=fields[3].f32()
	// 		pi.rss=fields[4].int()
	// 		fields.delete_many(0,6)			
	// 		println(fields)
	// 	}
	// }


}
