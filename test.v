module main

import despiegk.crystallib.digitaltwin
import despiegk.crystallib.redisclient

fn main() {
	mut redis := redisclient.connect('localhost:6379') or { panic(err) }

	digitaltwin.bootstrap_test_populate(mut &redis)
}
