module main

import appsbox.redisapp

fn do() ? {
	// get local client to redis
	mut client := redisapp.client_local_get()?
}

fn main() {
	do() or { panic(err) }
}
