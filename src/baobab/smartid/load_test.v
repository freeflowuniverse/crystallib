module smartid

import freeflowuniverse.crystallib.clients.redisclient

fn test_load() {
	defer {
		cleanup(mut redis) or { panic(err) }
	}

	t := '
	
'
	// TODO: sid_empty_replace
}
