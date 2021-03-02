module msgbus

import despiegk.crystallib.redisclient
import time
import json
import despiegk.crystallib.digitaltwin

struct MSGBusConnection {
mut:
	// who am I
	me           digitaltwin.DigitalTwinME
	twin_factory digitaltwin.DigitalTwinFactory
	redis        &redisclient.Redis
}

pub fn new(redis &redisclient.Redis) ?MSGBusConnection {
	mut twin_factory := digitaltwin.factory(redis) ?
	return MSGBusConnection{
		redis: redis
		twin_factory: twin_factory
		me: twin_factory.me
	}
}

// cmd is dot notation
pub fn (mut bus MSGBusConnection) send(mut msg Message) ? {
	for mut twin in msg.twin_dest {
		lastid := bus.redis.incr('bus:lastid') ?
		mut msg_ll := MessageLowLevel{
			id: lastid
			cmd: msg.cmd
			expiration: msg.expiration.epoch()
			data: msg.data
			schema: msg.schema
			twin_source: bus.me.id()
			twin_dest: twin.id()
			return_queue: msg.return_queue
			fingerprint: ''.bytes()
			signature: ''.bytes()
			direction: 'o'
			epoch: time.now().unix_time()
		}
		msg_ll.sign(mut bus.twin_factory)
		// if multiple destinations then will set it on multiple queues
		data_json := json.encode(msg_ll)

		bus.redis.hset('bus:msg', '$msg_ll.id', data_json) ?

		mut q := bus.redis.queue_get('bus:out:$msg_ll.twin_dest')
		q.add('$msg_ll.id') ?
	}
}
