module main

// import freeflowuniverse.crystallib.chapters
import freeflowuniverse.crystallib.gittools
import os

// const path0 = '~/code/github/threefoldfoundation/books'

const reset = false

fn do() ! {
	mut path := ''

	mut gs := gittools.get(root: '/tmp/code')!

	url := 'git@github.com:threefoldfoundation/books.git'
	mut gr := gs.repo_get_from_url(url: url, pull: false, reset: reset)!
	path = gr.path

	// chapters.scan(path + '/content')!

	// mut chapters := chapters.books_new(&chapters)
	// chapters.scan(path + '/chapters')!

	// // println(chapters.chapters["ppp"])
	// mut b := chapters.get('abundance_internet')!

	// b.mdbook_export()!

	panic("not implemented")
}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
