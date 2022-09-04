module main

import tmux
import redisclient

fn do() ? {
	mut b_local := tmux.executor_new(local: true)
	mut b_ssh := tmux.executor_new(ipaddr: '212.2.3.3')

	println(b_local)
	println(b_ssh)
}

fn main() {
	do() or { panic(err) }
}
