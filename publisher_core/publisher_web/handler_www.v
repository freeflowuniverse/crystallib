
module publisher_web



fn (mut app App) handle_www(path string ) ?vweb.Result {

	//TODO: need to deal with finding the location for default web pages

	panic("not implemented")
	
	mut path2 := path

	if path2.trim('/') == '' {
		path2 = 'index.html'
		app.set_content_type('text/html')
	}
	path2 = os.join_path(site_path, path2)

	if !os.exists(path2) {
		println(' - ERROR: cannot find path:$path2')
		return app.not_found()
	} else {
		if os.is_dir(path2) {
			path2 = os.join_path(path2, 'index.html')
			app.set_content_type('text/html')
		}

		if path.ends_with('.html') {
			mut content := os.read_file(path2) or { return app.not_found() }
			content = domain_replacer(rlock app.ctx {
				app.ctx.webnames
			}, content)
			return app.html(content)
		} else {
			// println("deliver: '$path2'")
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			content2 := os.read_file(path2) or { return app.not_found() }
			app.set_content_type(content_type_get(path2)?)
			return app.ok(content2)
		}
	}
}
