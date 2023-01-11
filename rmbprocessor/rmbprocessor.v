module rmbprocessor
import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.resp

import time

pub struct RMBProcessor{
pub mut:
	rmbc rmbclient.RMBClient
}

//twinid, is my id for me as twin
//list of proxyipaddr is the proxies I can connect too, the first one is most priority
pub fn new(twinid u32,proxyipaddr[]string) !RMBProcessor{
	mut rmbclient :=rmbclient.new()!
	rmbclient.twinid=twinid
	mut rmbp:=RMBProcessor{rmbc:rmbclient}
	rmbp.twinid=twinid

	//TODO: call towards rmbproxy
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
			if job.twinid==u32(0) || job.twinid==rmb.rmbclient.iam.twinid {
				rmb.redis.lpush("jobs.queue.in","${job.guid}")!
				now:=time.now().unix_time()
				rmb.redis.hset("rmb.jobs.in","${job.guid}","$now")!
			}else{
				// TODO should we put the guid in redis and let Proxy iterate over it? 
				now:=time.now().unix_time()
				rmb.redis.hset("rmb.jobs.clients.${}", "${job.guid}", "$now")!
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