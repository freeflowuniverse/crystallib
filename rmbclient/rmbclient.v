module rmbclient

import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.params { Params }
import freeflowuniverse.crystallib.ipaddress
import json
import time
import rand

pub struct RMBClient{
pub mut:
	redis redisclient.Redis
	iam MyTwin
}

pub fn new() !RMBClient{
	mut redis := redisclient.core_get()
	mut rmb:=RMBClient{redis:redis,iam:MyTwin{}}
	iamdata:=rmb.redis.get("rmb.iam")!
	if !(iamdata.len==0){
		iamo:=json.decode(MyTwin,iamdata)!
		rmb.iam=iamo
	}
	return rmb
}

//if rmbid is 0, means we work in local mode
// 		src_twinid		 u32    //which twin is responsible for executing on behalf of actor (0 is local)
// 		src_rmbids		 []u32  //how do we find our way back, if 0 is local, can be more than 1
// 		ipaddr			 string
pub fn (mut rmb RMBClient) iam_register(args MyTwin)!{
	mut ipaddr0:=args.ipaddr
	if ipaddr0==""{
		ipaddr0="localhost"
	}
	ipaddr:=ipaddress.ipaddress_new(ipaddr0)!
	twin:=MyTwin {
		src_twinid: args.src_twinid
		src_rmbids:args.src_rmbids
		ipaddr:ipaddr0
	}
	data:=twin.dumps()!
	rmb.redis.set("rmb.iam",data)!
	rmb.iam=twin
}

// creates new actionjob
pub fn (mut rmb RMBClient) action_new(twinid u32, action string, params Params,actionsource string) !ActionJob {
	return ActionJob{
		guid:rand.uuid_v4()
		twinid:twinid
		action:action
		params: params
		start: time.now()
		src_action:actionsource
		src_twinid:rmb.iam.src_twinid
		src_rmbids:rmb.iam.src_rmbids
	}
}

pub fn (mut rmb RMBClient) action_new_schedule(twinid u32, action string, params Params,actionsource string) !ActionJob {
	mut job:=rmb.action_new(twinid,action,params,actionsource)!
	rmb.action_schedule(mut job)!
	return job
}

pub fn (mut rmb RMBClient) action_new_wait(twinid u32, action string, params Params,actionsource string) !ActionJob {
	mut job:=rmb.action_new(twinid,action,params,actionsource)!
	rmb.action_schedule_wait(mut job)!
	return job
}

//schedules the job to be executed
pub fn (mut rmb RMBClient) action_schedule(mut job ActionJob)!{
	job.state=.tostart
	rmb.job_set(job)!
	rmb.redis.lpush("jobs.queue.out","${job.guid}")!
	now:=time.now().unix_time()
	rmb.redis.hset("rmb.jobs.out","${job.guid}","$now")!
}

//get the job back from redis
pub fn (mut rmb RMBClient) job_get(guid string)!ActionJob{
	data :=rmb.redis.hget("rmb.jobs.db","${guid}") or {return error("Cannot find job: ${guid}.\n$err")}
	mut job:=job_load(data)!
	return job
}

//store the job in the local redis
pub fn (mut rmb RMBClient) job_set(job ActionJob)!{
	data := job.dumps()!
	rmb.redis.hset("rmb.jobs.db","${job.guid}",data)!
}

//schedules the job to be executed and then wait on return
pub fn (mut rmb RMBClient) action_schedule_wait(mut job ActionJob)!{
	rmb.action_schedule(mut job)!
}

pub fn (mut rmb RMBClient) reset()!{
	rmb.redis.del("rmb.jobs.db")!
	rmb.redis.del("rmb.jobs.out")!
	rmb.redis.del("rmb.jobs.in")!
	rmb.redis.del("rmb.iam")!
	rmb.redis.del("jobs.queue.out")!
	rmb.redis.del("jobs.queue.in")!

	//need to save the info we still have in mem to redis
	data:=rmb.iam.dumps()!
	rmb.redis.set("rmb.iam",data)!

}
