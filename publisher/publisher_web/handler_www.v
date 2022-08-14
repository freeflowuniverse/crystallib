
module publisher_web

import vweb
import os
import path as crystalpath

fn (mut app App) handle_www(siteroot_ string, relpath_ string ) ?vweb.Result {

	mut siteroot := crystalpath.get(siteroot_)

	mut relpath := relpath_

	if relpath.trim('/') == '' {
		relpath = 'index.html'
		app.set_content_type('text/html')
	}	

	mut wl := wiki_location_parser(siteroot,relpath)?
	mut pathfull := os.join_path(siteroot.path,relpath)

	// $if debug {
	// 	eprintln(" - '${wl.sitename}:${wl.name}' -> $pathfull")
	// }	

	if !os.exists(pathfull) {
		println(' - ERROR: cannot find path:$pathfull')
		return app.not_found()
	} else {
		if os.is_dir(pathfull) {
			pathfull = os.join_path(pathfull, 'index.html')
			app.set_content_type('text/html')
		}

		if pathfull.ends_with('.html') {
			mut content := os.read_file(pathfull) or { return app.not_found() }
			return app.html(content)
		} else {
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			content2 := os.read_file(pathfull) or { return app.not_found() }
			app.set_content_type(content_type_get(pathfull)?)
			return app.ok(content2)
		}
	}
}
