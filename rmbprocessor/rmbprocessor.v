module rmbprocessor
import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.resp

import time

pub struct RMBProcessor{
pub mut:
	rmbc rmbclient.RMBClient
}

pub fn new() !RMBProcessor{
	mut rmbclient :=rmbclient.new()!
	mut rmbp:=RMBProcessor{rmbc:rmbclient}
	return rmbp
}

//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
fn (mut rmbp RMBProcessor) process()!{
	mut rmb:=&rmbp.rmbc
	mut guid:=""
	for{
		guid=rmb.redis.rpop("jobs.queue.out") or {
			println(err)
			panic("error in jobs queue")
		}
		if guid.len>0{		
			println("FOUND OUTGOING GUID:$guid")
			mut job:=rmb.job_get(guid)!
			if job.twinid==u32(0) || job.twinid==rmb. {
				rmb.redis.lpush("jobs.queue.in","${job.guid}")!
				now:=time.now().unix_time()
				rmb.redis.hset("rmb.jobs.in","${job.guid}","$now")!
			}else{

			}
			println(job)
		}
		println("sleep")
		time.sleep(time.second)
		// mut job4:=rmb.job_get(qout)!
		// println(job4)
	}

}

//run the rmb processor
pub fn process()!{
	mut rmbp:=new()!
	rmbp.process()!
}