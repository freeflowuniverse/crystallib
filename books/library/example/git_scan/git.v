module main

import freeflowuniverse.crystallib.books.chapter

// const path0 = '~/code/github/threefoldfoundation/books'

const reset = true

fn do() ! {
	mut c := chapter.chapter_new(
		git_root: '~/code5'
		git_url: 'https://github.com/threefoldfoundation/books/tree/main/content/mytwin'
		load: true
		heal: true
		name: 'Scanner1'
		git_reset: reset
	)!
}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
