
module publisher_web


// import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_core


//get the html frontpage for a wiki website
fn wiki_frontpage_get (mut publisher &publisher_core.Publisher) string {
	sites := publisher.config.sites_get([])
	web_hostnames := publisher.config.web_hostnames
	mut port_str := ''
	if publisher.config.publish.port != 80 {
		port_str = ':$publisher.config.publish.port'
	}
	return $tmpl('templates/index_root.html')
}


// sitename is name for site
fn (mut app App) handle_wiki(path0 string) ?vweb.Result {
	mut path := path0

	$if debug {
		eprintln(' >>> Webserver >> path >> $path0')
		// println(' >>> Webserver >> req >> $req')
		// println(' >>> Webserver >> res >> $res')		
	}

	mut publisher := rlock app.ctx {
		app.ctx.publisher
	}

	mut wl := wiki_location_parser(path)?

	//this means the content will come from memory in the publishing tools
	if publisher.develop {

		if wl.pagename=="" and wl.sitename=="" {
			//return html which is the front page for the wiki
			return app.ok(wiki_frontpage_get(mut &publisher)
		}

		if path.ends_with('errors') || path.ends_with('error') || path.ends_with('errors.md')
			|| path.ends_with('error.md') {
			app.set_content_type('text/html')
			return return_html_errors(wl.sitename, mut app)
		}

		$if debug {
			eprintln(' >> get develop: $wl.filetype, $wl.sitename, $wl.pagename')
		}

		if wl.filetype == FileType.javascript || wl.filetype == FileType.css {
			$if debug {
				eprintln(' >>> file static')
			}

			mut p := os.join_path(publisher.config.publish.paths.base, 'static', name2)
			mut content := os.read_file(p) or {
				$if debug {
					eprintln(' >>> file static not found or error: $p\n$err')
				}
				return app.not_found()
			}
			app.set_content_type(content_type_get(p)?)
			$if debug {
				content_type := content_type_get(p)?
				len1 := content.len
				eprintln(' >>> file static content type: $content_type, len:$len1')
			}
			return app.ok(content)
		}

		mut site2 := publisher.site_get(sitename2) or { return app.not_found() }
		if name2 == 'index.html' {
			// mut index := os.read_file( site.path + '/index.html') or {
			// 	res.send("index.html not found", 404)
			// }
			site_config := publisher.config.site_wiki_get(sitename2)?
			index_out := publisher.template_wiki_root(sitename, '', '', site_config.opengraph)?
			return app.html(index_out)
		} else if wl.filetype == FileType.wiki {
			if site2.page_exists(wl.pagename) {
				mut page := site2.page_get(wl.pagename, mut publisher)?
				mut content := page.content_get(mut publisher, false, true) or {
					return app.server_error(2)
				}
				// content = domain_replacer(rlock app.ctx {
				// 	app.ctx.webnames
				// }, content)
				return app.ok(content)
			} else {
				mut page_def := publisher.def_page_get(wl.pagename)?
				// content := page_def.replace_defs(mut publisher, page_def.content) or { return app.server_error(3) }
				// if debug {println(" >> page send: $name2")}
				// content2 := domain_replacer(rlock app.ctx {
				// 	app.ctx.webnames
				// }, page_def.content)
				mut content := page_def.content_get(mut publisher, false, true) or {
					return app.server_error(2)
				}
				return app.ok(content)
			}
		} else {
			// now is a file
			file3 := site2.file_get(wl.pagename, mut publisher)?
			path3 := file3.path_get(mut publisher)?
			$if debug {
				eprintln(' >> file get: $path3')
			}
			content3 := os.read_file(path3) or { return app.not_found() }
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			app.set_content_type(content_type_get(path3)?)
			return app.ok(content3)
		}
	} else {

		//TODO, should come in other way
		ppaths := publisher.publisher.config.publish.paths

		mut path2 := os.join_path(ppaths.publish, wl.sitename, wl.pagename)
		if name == 'readme.md' && (!os.exists(path2)) {
			name = 'sidebar.md'
			path2 = os.join_path(ppaths.publish, sitename, name)
		}

		if !os.exists(path2) {
			return error('cannot find file in: $path2')
		}

		filetype, path2 := path_wiki_get(config, sitename, name) or {
			println(' - ERROR: could not get path for: $sitename:$name\n$err')
			return app.not_found()
		}
		$if debug {
			eprintln(" - '${wl.sitename}:${wl.name}' -> $path2")
		}
		if wl.filetype == FileType.wiki {
			content := os.read_file(path2) or { return app.not_found() }
			return app.html(content)
		} else {
			if !os.exists(path2) {
				println(' - ERROR: cannot find path:$path2')
				return app.not_found()
			} else {
				// println("deliver: '$path2'")
				content := os.read_file(path2) or { return app.not_found() }
				// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
				app.set_content_type(content_type_get(path2)?)
				return app.ok(content)
			}
		}
	}
}