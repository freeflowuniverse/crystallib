module smartid

import freeflowuniverse.crystallib.clients.redisclient

fn cleanup() ! {
	mut r := redisclient.core_get()!
	all_keys := r.keys('circle:*')!
	for key in all_keys {
		r.del(key)!
	}
}

fn test_cid() {
	cleanup() or { panic(err) }

	for i in 0 .. 10000 {
		cid := cid_get(name: 'test_${i}')!
	}

	cid := cid_get(id_int: 9999)!
	assert cid.str() == '7pr'
	assert cid.u32() == 9999
	assert cid.name() == 'test_9988'

	cid2 := cid_get(id_int: 9998)!
	assert cid2.str() == '7pq'
	assert cid2.u32() == 9998
	assert cid2.name() == 'test_9987'

	g1 := cid.gid_get('1')!
	g2 := cid.gid_get('2')!

	// println(g1)
	// println(g2)
	// if true{panic("sdf")}

	assert g2 == GID{
		region: 0
		circle: 9999
		id: 2
	}

	g3 := cid.gid_new()!
	assert g3 == GID{
		region: 0
		circle: 9999
		id: 11
	}

	g4 := cid.gid_new()!
	assert g4 == GID{
		region: 0
		circle: 9999
		id: 12
	}

	cleanup() or { panic(err) }
}
