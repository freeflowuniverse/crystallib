module main

import builder
import redisclient

fn do() ? {
	mut rc := redisclient.core_get()?
	mut builder := builder.new(rc)?
	n := builder.node_local()?
	res := n.executor.execute('ls /')
	println(res)
}

fn main() {
	do() or { panic(err) }
}
