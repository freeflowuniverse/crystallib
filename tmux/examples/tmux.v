module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.tmux

fn do()! {
	mut t := tmux.get_local()!

	t.window_new(name: 'test', cmd: 'mc', reset: true)?


}

fn main() {
	do() or { panic(err) }
}
