module main2

import freeflowuniverse.crystallib.imagemagick
import gittools

fn do() ? {
	if !imagemagick.installed() {
		panic('need imagemagick')
	}

	mut gs := gittools.get(root: '/tmp/code')?

	url := 'https://github.com/threefoldfoundation/www_examplesite/tree/development/src'
	mut gr := gs.repo_get_from_url(url: url, pull: false, reset: false)?
	gr.remove_changes()?

	path := gr.path_content_get() // path of the manual

	imagemagick.scan(path: path, backupdir: '/tmp/backupimages')?

	// remove changes so we can do again
	// gr.remove_changes()?
}

fn main2() {
	do() or { panic(err) }
}
