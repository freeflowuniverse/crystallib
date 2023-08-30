module main

import freeflowuniverse.crystallib.apps.syncthing

fn do() ! {
	mut a:=syncthing.new()!
	a.query()!
}

fn main() {
	do() or { panic(err) }
}
