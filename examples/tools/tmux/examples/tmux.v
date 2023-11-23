module main

import freeflowuniverse.crystallib.osal.tmux

fn do() ! {
	mut t := tmux.new()!
	t.session_delete('main')!
	println(t)
	t.window_new(name: 'test', cmd: 'mc', reset: true)!
	println(t)
}

fn main() {
	do() or { panic(err) }
}
