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
		cid2 := cid(name: 'test_${i}')!
	}

	cid1 := cid(cid_int: 9999)!
	assert cid1.str() == '7pr'
	assert cid1.u32() == 9999
	assert cid1.name() == 'test_9988'

	cid2 := cid(cid_int: 9998)!
	assert cid2.str() == '7pq'
	assert cid2.u32() == 9998
	assert cid2.name() == 'test_9987'

	g1 := cid1.gid(oid_str: '1')!
	g2 := cid1.gid(oid_str: '2')!

	println(g1)
	println(g2)

	cido := CID{
		circle: 9999
	}

	assert g2 == GID{
		region: 0
		cid: cido
		id: 2
	}

	g3 := cid1.gid()!
	assert g3 == GID{
		region: 0
		cid: cido
		id: 11
	}

	g4 := cid1.gid()!
	assert g4 == GID{
		region: 0
		cid: cido
		id: 12
	}

	cleanup() or { panic(err) }
}
