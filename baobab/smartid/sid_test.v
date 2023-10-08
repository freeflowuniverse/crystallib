module smartid
import freeflowuniverse.crystallib.redisclient

fn cleanup() ! {
	mut r := redisclient.core_get()!
	all_keys := r.keys('circle:test:*')!
	for key in all_keys {
		r.del(key)!
	}	
}

fn test_sid() {
	defer {
		cleanup() or { panic(err) }
	}

	for i in 0..10000{
		sid_new("test")!
	}

	//TODO: aknowledge sid's, do tests if the right ones are in there, ...	

	//TODO: test sid_str, int, ... the checks, ...

	// cleanup()

}
