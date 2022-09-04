module main

import freeflowuniverse.crystallib.imagemagick
import gittools

fn do() ? {
	imagemagick.install()?

	mut gs := gittools.get(root: '/tmp/code')?

	url := 'https://github.com/threefoldfoundation/www_examplesite/tree/development/manual'
	mut gr := gs.repo_get_from_url(url: url, pull: false, reset: false)?

	path := gr.path_content_get() // path of the manual

	// remove changes so we can do again
	gr.remove_changes()?
}

fn main() {
	do() or { panic(err) }
}
