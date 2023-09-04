module main

import freeflowuniverse.crystallib.apps.syncthing
import time

fn do() ! {
	mut a := syncthing.new()!
	for t in 0 .. 1111111111 {
		a.query()!
		time.sleep(time.Duration(10 * time.second))
	}
}

fn main() {
	do() or { panic(err) }
}
