module main

import freeflowuniverse.crystallib.books
import freeflowuniverse.crystallib.gittools
import os

const path0 = '~/code/github/threefoldfoundation/books'
const reset = false

fn do() ! {

	mut path:=""

	if reset || (! os.exists(path)){
		mut gs := gittools.get(root:"/tmp/code")!

		url := 'git@github.com:threefoldfoundation/books.git'
		mut gr := gs.repo_get_from_url(url: url, pull: false, reset: reset)!
		path = gr.path
	}else{
		path = path0
	}

	mut sites := books.sites_new()
	sites.scan(path + '/content')!

	mut books := books.books_new(&sites)
	books.scan(path + '/books')!

	// println(sites.sites["ppp"])
	mut b := books.get('abundance_internet')!

	b.mdbook_export()!
}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
