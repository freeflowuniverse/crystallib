
module publisher_macros

//main handler

['/:path...']
pub fn (mut app App) handler(_path string) vweb.Result {
	publisher := rlock app.ctx {app.ctx.publisher}
	mut path := _path

	// enable CORS by default
	app.add_header('Access-Control-Allow-Origin', '*')

	// println(" ++ $path")

	mut domain := ''
	// mut cat := publisher_config.SiteCat.web

	mut sitename := ''
	mut iswiki := false

	if publisher.config.web_hostnames {
		host := app.get_header('Host')
		if host.len == 0 {
			panic('Host is missing')
		}
		domain = host.all_before(':')
	} else {
		path = path.trim('/')

		if path == 'info' {
			return app.html(index_template(config))
		}

		if path.starts_with('info/') {
			path = path[5..]
			iswiki = true
			// cat = publisher_config.SiteCat.wiki
			// } else {
			// 	cat = publisher_config.SiteCat.web
		}

		splitted := path.split('/')

		//TODO: think we're dealing with this also in wiki parts, might be double

		sitename = splitted[0]
		path = splitted[1..].join('/').trim('/').trim(' ')
		if splitted.len == 1 && (sitename.ends_with('.css') || sitename.ends_with('.js')) {
			p := os.join_path(publisher.config.publish.paths.base, 'static', sitename)
			content := os.read_file(p) or { return app.not_found() }
			app.set_content_type(content_type_get(p) or { return app.not_found() })
			return app.ok(content)
		}

		// if sitename == '' {
		// 	domain = 'localhost'
		// } else {
		// 	domain = publisher.config.domain_get(sitename, cat) or { return app.not_found() }
		// 	println('DOMAIN:$domain')
		// }
	}

	if domain == 'localhost' || sitename == '' {
		return app.html(index_template(config))
	}

	//
	// mut domainfound := false
	// for siteconfig in publisher.config.sites {
	// 	println(" ---- $sitename $siteconfig.name")
	// 	if domain in siteconfig.domains || texttools.name_fix(sitename) == texttools.name_fix(siteconfig.name) {
	// 		domainfound = true
	// 		if siteconfig.cat == publisher_config.SiteCat.web {
	// 			iswiki = false
	// 		}
	// 		break
	// 	}
	// }

	// if !domainfound {
	// 	return app.not_found()
	// }

	if !iswiki {
		if publisher.develop {
			return app.not_found()
		}
		return app.handle_www(path, mut app) or { app.server_error(1) }
	} else {
		return app.handle_wiki(path) or { app.not_found() }
	}
}
