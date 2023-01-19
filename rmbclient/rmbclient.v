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
	// A map from jobaction to queue name. The jobaction can be domain, domain.actor or even domain.actor.method
	actor_coordinates map[string]string
}

pub fn new() !RMBClient {
	mut redis := redisclient.core_get()
	mut rmb := RMBClient{ redis: redis }
	
	twinid := rmb.redis.get("rmb.mytwin.id") or {
		return error("rmb.mytwin.id not set")
	}
	rmb.twinid = twinid.u32()

	actor_coordinates_data := rmb.redis.hgetall("rmb.actorcoordinates") or {
		return error("rmb.actorcoordinates not set")
	}
	// TODO maybe we can hget when rescheduling so that actors can be added at runtime
	for actor in actor_coordinates_data {
		rmb.actor_coordinates["$actor"] = rmb.redis.hget("rmb.actorcoordinates", "$actor") or {
			return error("failed to hget rmb.actorcoordinates $actor")
		}
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

// put the job in the first queue of the first actor that matches the action of the job
pub fn (mut rmb RMBClient) reschedule_to_actor(job ActionJob) ! {
	for actor, queue in rmb.actor_coordinates {
		if job.action.starts_with(actor) {
			rmb.redis.lpush(queue, "${job.guid}")!
			now := time.now().unix_time()
			rmb.redis.hset("rmb.jobs.in", "${job.guid}", "$now")!
		}
	}
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
	for k, v in rmb.actor_coordinates {
		rmb.redis.hset("rmb.actorcoordinates", k, v)!
	}
}
