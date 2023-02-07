module actionrunner

import time
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.jobs
import freeflowuniverse.crystallib.redisclient

fn test_run() {
	client := client.new() or { panic(err) }
	mut ar := new(client) or { panic(err) }
	spawn (&ar).run()
	mock_processor('crystallib.git.commit', true)!
}

fn mock_processor(action string, add_to_db bool) ! {
	mut redis := redisclient.core_get()
	job := jobs.new(twinid: 0, action: action)!

	// add job to jobs.db
	if add_to_db {
		redis.hset('jobs.db', job.guid, job.json_dump())!
	}

	// add the guid to the queue for the appropriate actor
	q_key := 'jobs.actors.${job.action.all_before_last('.')}'
	mut q_actor := redis.queue_get(q_key)
	q_actor.add(job.guid)!

	time.sleep(5000000)

	// check error and result queues to see if any guids were returned
	mut q_error := redis.queue_get('jobs.processor.error')
	mut q_result := redis.queue_get('jobs.processor.result')
	guid_error := q_error.pop() or { '' }
	guid_result := q_result.pop() or { '' }

	assert guid_error == job.guid || guid_result == job.guid
}
