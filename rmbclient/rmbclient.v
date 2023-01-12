module rmbclient

import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.params { Params }

import json 
import rand
import time

pub struct RMBClient{
pub mut:
	redis redisclient.Redis
	twinid u32
	rmb_proxy_ips []string
}

pub fn new() !RMBClient {
	mut redis := redisclient.core_get()
	mut rmb := RMBClient{ redis: redis }
	
	twinid := rmb.redis.get("rmb.mytwin.id") or {
		return error("rmb.mytwin.id not set")
	}
	if twinid == "" {
		return error("rmb.mytwin.id not set")
	}
	rmb.twinid = twinid.u32()

	rmb_proxy_ips := rmb.redis.get("rmb.mytwin.proxyips") or {
		return error("rmb.mytwin.proxyips not set")
	}
	if rmb_proxy_ips == "" {
		return error("rmb.mytwin.proxyips not set")
	}
	rmb.rmb_proxy_ips = json.decode([]string, rmb_proxy_ips) or {
		return error("failed decoding \"${rmb_proxy_ips}\" to []string")
	}
	return rmb
}

// creates new actionjob
pub fn (mut rmb RMBClient) action_new(twinid u32, action string, args Params, actionsource string) !ActionJob {
	return ActionJob{
		guid: rand.uuid_v4()
		twinid: twinid
		action: action
		args: args
		start: time.now()
		src_action: actionsource
		src_twinid: rmb.twinid
	}
}

pub fn (mut rmb RMBClient) action_new_schedule(twinid u32, action string, args Params, actionsource string) !ActionJob {
	mut job := rmb.action_new(twinid, action, args, actionsource)!
	rmb.action_schedule(mut job)!
	return job
}

pub fn (mut rmb RMBClient) action_new_wait(twinid u32, action string, args Params, actionsource string) !ActionJob {
	mut job := rmb.action_new(twinid, action, args, actionsource)!
	rmb.action_schedule_wait(mut job)!
	return job
}

//schedules the job to be executed
pub fn (mut rmb RMBClient) action_schedule(mut job ActionJob) ! {
	job.state = .tostart
	rmb.job_set(job)!
	rmb.redis.lpush("jobs.queue.out", "${job.guid}")!
	now := time.now().unix_time()
	rmb.redis.hset("rmb.jobs.out", "${job.guid}", "$now")!
}

//get the job back from redis
pub fn (mut rmb RMBClient) job_get(guid string) !ActionJob {
	data := rmb.redis.hget("rmb.jobs.db", "${guid}") or {
		return error("Cannot find job: ${guid}.\n$err")
	}
	mut job := job_load(data)!
	return job
}

//store the job in the local redis
pub fn (mut rmb RMBClient) job_set(job ActionJob) ! {
	data := job.dumps()
	rmb.redis.hset("rmb.jobs.db", "${job.guid}", data)!
}

pub fn (mut rmb RMBClient) next_job_guid() !string {
	guid := rmb.redis.rpop("jobs.queue.out")!
	return guid
}

pub fn (mut rmb RMBClient) reschedule_in(guid string) ! {
	rmb.redis.lpush("jobs.queue.in", "${guid}")!
	now := time.now().unix_time()
	rmb.redis.hset("rmb.jobs.in", "${guid}", "$now")!
}

pub fn (mut rmb RMBClient) del_twin(twin_id u32) ! {
	rmb.redis.del("rmb.twins.${twin_id}")!
}

pub fn (mut rmb RMBClient) set_twin(twin_id u32, twin string) ! {
	max_twin_id := rmb.redis.get("rmb.twins.max_twin_id")!.u32()
	if max_twin_id < twin_id {
		rmb.redis.set("rmb.twins.max_twin_id", twin_id.str())!
	}
	rmb.redis.set("rmb.twins.${twin_id}", twin)!
}

pub fn (mut rmb RMBClient) get_twin(twin_id u32) !string {
	twin := rmb.redis.get("rmb.twins.${twin_id}")!
	return twin
}

pub fn (mut rmb RMBClient) new_twin_id() !u32 {
	max_twin_id := rmb.redis.get("rmb.twins.max_twin_id")!.u32()
	return max_twin_id + 1
}

//schedules the job to be executed and then wait on return
pub fn (mut rmb RMBClient) action_schedule_wait(mut job ActionJob) ! {
	rmb.action_schedule(mut job)!
}

pub fn (mut rmb RMBClient) reset() ! {
	rmb.redis.del("rmb.jobs.db")!
	rmb.redis.del("rmb.jobs.out")!
	rmb.redis.del("rmb.jobs.in")!
	rmb.redis.del("rmb.iam")!
	rmb.redis.del("rmb.twins.max_twin_id")!
	rmb.redis.del("jobs.queue.out")!
	rmb.redis.del("jobs.queue.in")!

	//need to save the info we still have in mem to redis
	rmb.redis.set("rmb.mytwin.id", rmb.twinid.str())!
}
