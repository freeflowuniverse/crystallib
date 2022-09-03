module main

import gittools
import os

const testpath = os.dir(@FILE) + '/book1'

fn do() ? {
	mut gs := gittools.get(root: '/tmp/code')?

	url := 'https://github.com/threefoldfoundation/www_examplesite/tree/development/manual'
	mut gr := gs.repo_get_from_url(url: url, pull: false, reset: false)?

	gs.repos_print(filter: '')

	// println(gr)

	// this will show the exact path of the manual
	println(gr.path_content_get())
}

fn main() {
	do() or { panic(err) }
}
