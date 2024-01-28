module hetzner
import json
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.clients.redisclient
import time
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal { ping }

pub struct SSHKey {
pub mut:
    name        string
    fingerprint string
    type_        string @[json: 'type']
    size        int
    created_at  string
    data        string
}

struct SSHRoot {
    key SSHKey
}


pub fn (h HetznerClient) keys_get() ![]SSHKey {

	mut redis := redisclient.core_get()!
	mut rkey:='hetzner.api.get.${h.instance}'
	mut data:=redis.get(rkey)!
	if data=="" {
		data = h.request_get("/key")!
	}

	redis.set(rkey,data)!
	redis.expire(rkey, 120)! //only cache for 1 minute

	// println(data)

	items := json.decode([]SSHRoot, data) or {
		return error("could not json deserialize for servers_list\n$data")
	}

	mut result := items.map(it.key)
	return result
}



pub fn (h HetznerClient) key_set() ! {

	// key SSHKey

	//TODO: need to get keys also from ssh agent

}

