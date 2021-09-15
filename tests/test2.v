module main

import crystallib.redisclient

fn main() {
	mut redis := redisclient.connect('localhost:6379') or { panic(err) }

	println(redis)
}
