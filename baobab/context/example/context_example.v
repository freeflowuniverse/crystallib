
module main

import freeflowuniverse.crystallib.baobab.context

fn do() ! {

	mut c:=context.new()!


	tree.scan(
		git_root: '~/code6'
		git_url: 'https://github.com/threefoldfoundation/books/tree/main/content'
		load: true
		heal: false
		git_reset: reset
	)!


	println(h)
}

fn main() {
	do() or { panic(err) }
}
