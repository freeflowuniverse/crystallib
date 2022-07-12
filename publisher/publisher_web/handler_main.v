
module publisher_web

import vweb
import os
//main handler, can be done smarter

['/:path...']
pub fn (mut app App) handler(path string) vweb.Result {
	mut path2 := path

	// enable CORS by default
	app.add_header('Access-Control-Allow-Origin', '*')

	// println(" ++ $path")

	// host := app.get_header('Host')
	// if host.len == 0 {
	// 	panic('Host is missing')
	// }
	// domain = host.all_before(':')

	path2 = path2.trim('/')

	if path2 == 'info' {
		return app.html(app.wiki_frontpage_get())
	}

	mut iswiki := false

	if path2.starts_with('info/') {
		path2 = path[5..]
		iswiki = true
	}

	splitted := path2.split('/')

	sitename := splitted[0]
	path2 = splitted[1..].join('/').trim('/').trim(' ')
	if splitted.len == 1 && (sitename.ends_with('.css') || sitename.ends_with('.js')) {
		p := os.join_path(path, 'static', sitename)
		content := os.read_file(p) or { return app.not_found() }
		app.set_content_type(content_type_get(p) or { return app.not_found() })
		return app.ok(content)
	}

	if sitename == '' {
		return app.html(app.wiki_frontpage_get())
	}

	mut ctx := rlock app.ctx {
		app.ctx
	}	

	sitepath := ctx.config.publish.paths.publish

	mut site:= ctx.config.site_web_get(sitename) or {
					return app.not_found() 
				}

	// if !iswiki {
	// 	return app.handle_www(site.path,sitename) or { app.server_error(1) }
	// } else {
	// 	return app.handle_wiki(site.path,sitename) or { app.not_found() }
	// }
	return  app.not_found()
}
