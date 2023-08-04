module actionrunner

import time
import freeflowuniverse.crystallib.baobab.actor
import freeflowuniverse.crystallib.baobab.client
import freeflowuniverse.crystallib.baobab.jobs
import freeflowuniverse.crystallib.redisclient

fn testsuite_begin() {
	mut redis := redisclient.core_get()!
	redis.flushall()!
	redis.disconnect()
}

struct TestActor {
	name string = 'test.actor'
}

fn (a TestActor) execute(mut job jobs.ActionJob) ! {
	return
}

fn test_run() {
	client_ := client.new('localhost:6379') or { panic(err) }
	test_actor := TestActor{}
	mut ar := new(client_, [&actor.IActor(test_actor)])
	spawn (&ar).run()
	mock_processor('test.actor.action', true)!
}

fn mock_processor(action string, add_to_db bool) ! {
	mut redis := redisclient.core_get()!
	job := jobs.new(twinid: 0, action: action)!

	// add job to jobs.db
	if add_to_db {
		redis.hset('jobs.db', job.guid, job.json_dump())!
	}

	// add the guid to the queue for the appropriate actor
	q_key := 'jobs.actors.${job.action.all_before_last('.')}'
	mut q_actor := redis.queue_get(q_key)
	q_actor.add(job.guid)!

	time.sleep(500000)

	// check error and result queues to see if any guids were returned
	res := redis.brpop(['jobs.processor.result'], 60)!
	assert res.len == 2
	guid_result := res[1]
	guid_error := redis.rpop('jobs.processor.error') or { '' }

	assert guid_error == ''
	assert guid_result == job.guid
}
