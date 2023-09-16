module main

import freeflowuniverse.crystallib.tmux

fn do() ! {
	mut t := tmux.new()!
	t.window_new(name: 'test', cmd: 'mc', reset: true)!
}

fn main() {
	do() or { panic(err) }
}
