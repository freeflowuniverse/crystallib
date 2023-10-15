module main

import crystallib.osal.gittools
import os


fn do() ! {
	mut gs := gittools.new(
		root: '${os.home_dir()}/code_backup'
	)!

	println(gs)

	mut gr := gittools.code_get(
		url: 'https://github.com/despiegk/ourworld_data'
	)!

	println(gr)

	// this will show the exact path of the manual
	// println(gr.path_content_get())
}

fn main() {
	do() or { panic(err) }
}
