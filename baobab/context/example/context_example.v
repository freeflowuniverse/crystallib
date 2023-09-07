module main

import freeflowuniverse.crystallib.baobab.context

fn do() ! {
	mut c := context.new()!


	c.gitstructure_new(gitname:"my",root:"~/code_remove")

	mut gs:=c.gitstructure("my")!

	println(gs)

	// tree.scan(
	// 	git_root: '~/code7'
	// 	git_url: 'https://github.com/threefoldfoundation/books/tree/main/content'
	// 	load: true
	// 	heal: false
	// 	git_reset: reset
	// )!

}

fn main() {
	do() or { panic(err) }
}
