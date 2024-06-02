module hetzner

import json
import freeflowuniverse.crystallib.clients.redisclient

pub struct SSHKey {
pub mut:
	name        string
	fingerprint string
	type_       string @[json: 'type']
	size        int
	created_at  string
	data        string
}

struct SSHRoot {
	key SSHKey
}

pub fn (mut h HetznerClient[Config]) keys_get() ![]SSHKey {
	mut redis := redisclient.core_get()!
	mut rkey := 'hetzner.api.get.${h.instance}'
	mut data := redis.get(rkey)!
	if data == '' {
		data = h.request_get('/key')!
	}

	redis.set(rkey, data)!
	redis.expire(rkey, 120)! // only cache for 1 minute

	// console.print_debug(data)

	items := json.decode([]SSHRoot, data) or {
		return error('could not json deserialize for servers_list\n${data}')
	}

	mut result := items.map(it.key)
	return result
}

pub fn (mut h HetznerClient[Config]) key_set() ! {
	panic('implement')
	// key SSHKey

	// TODO: need to get keys also from ssh agent
}
