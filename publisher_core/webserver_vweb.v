module publisher_core

import texttools
import os
import vweb
import publisher_config
import json

// this webserver is used for looking at the builded results

struct MyContext {
pub:
	config    		&publisher_config.ConfigRoot
pub mut:
	publisher 	&Publisher
	webnames 		map[string]string
}

enum FileType {
	unknown
	wiki
	file
	image
	html
	javascript
	css
}

fn path_wiki_get(config publisher_config.ConfigRoot, sitename_ string, name_ string) ?(FileType, string) {
	filetype, sitename, mut name := filetype_site_name_get(config, sitename_, name_) ?

	mut path2 := os.join_path(config.publish.paths.publish, sitename, name)
	if name == 'readme.md' && (!os.exists(path2)) {
		name = 'sidebar.md'
		path2 = os.join_path(config.publish.paths.publish, sitename, name)
	}
	// println('  > get: $path2 ($name)')

	if !os.exists(path2) {
		return error('cannot find file in: $path2')
	}
	return filetype, path2
}

fn filetype_site_name_get(config publisher_config.ConfigRoot, site string, name_ string) ?(FileType, string, string) {
	// println(" - wiki get: '$site' '$name'")
	site_config := config.site_wiki_get(site) ?
	mut name := name_.to_lower().trim(' ').trim('.').trim(' ')
	extension := os.file_ext(name).trim('.')
	mut sitename := site_config.name
	if sitename.starts_with('wiki_') || sitename.starts_with('info_') {
		return error('sitename short cannot start with wiki_ or info_.\n$site_config')
	}

	if name.contains('__') {
		parts := name.split('__')
		if parts.len != 2 {
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${name}.')
		}
		sitename = parts[0].trim(' ')
		if sitename == "tfgrid"{
			sitename = "threefold"
		}
		if sitename == "tokens"{
			sitename = "threefold"
		}
		if sitename == "cloud"{
			sitename = "threefold"
		}
		if sitename == "internet4"{
			sitename = "threefold"
		}		
		name = parts[1].trim(' ')
	}

	// println( " - ${app.req.url}")
	if name.trim(' ') == '' {
		name = 'index.html'
	} else {
		name = texttools.name_fix_keepext(name)
	}

	mut filetype := FileType{}

	if name.ends_with('.html') {
		filetype = FileType.html
	} else if name.ends_with('.md') {
		filetype = FileType.wiki
	} else if name.ends_with('.js') {
		name = name_
		filetype = FileType.javascript
	} else if name.ends_with('css') {
		name = name_
		filetype = FileType.css
	} else if extension == '' {
		filetype = FileType.wiki
	} else {
		filetype = FileType.file
	}

	if filetype == FileType.wiki {
		if !name.ends_with('.md') {
			name += '.md'
		}
	}

	if name == '_sidebar.md' {
		name = 'sidebar.md'
	}

	if name == '_navbar.md' {
		name = 'navbar.md'
	}

	if name == '_glossary.md' {
		name = 'glossary.md'
	}

	// println(" >>>WEB: filetype_site_name_get: $filetype-$sitename-$name")
	return filetype, sitename, name
}

fn index_template(config &publisher_config.ConfigRoot) string {
	sites := config.sites_get([])
	web_hostnames := config.web_hostnames
	mut port_str := ''
	if config.publish.port != 80 {
		port_str = ':$config.publish.port'
	}
	return $tmpl('index_root.html')
}

fn site_www_deliver(config publisher_config.ConfigRoot, domain string, path string, mut app App) ?vweb.Result {
	mut site_path := config.path_publish_web_get_domain(domain) or { return app.not_found() }
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
			app.set_content_type(content_type_get(path2) ?)
			return app.ok(content2)
		}
	}
}

fn site_wiki_deliver(config publisher_config.ConfigRoot, domain string, path string, mut app App) ?vweb.Result {
	mut path0 := path
	debug := false
	if debug {
		// println(' >>> Webserver >> config >> $config')
		// println(' >>> Webserver >> domain >> $domain')
		println(' >>> Webserver >> path >> $path0')
		// println(' >>> Webserver >> req >> $req')
		// println(' >>> Webserver >> res >> $res')
	}

	mut sitename := config.name_web_get(domain) or { return app.not_found() }
	if path0.contains("/") && path0.contains("sidebar"){
		path0 = path0.replace("/","|")
		path0 = path0.replace("||","|")
		path0 = path0.replace("_sidebar","sidebar")
	}
	name := os.base(path0)	
	mut publisherobj := rlock app.ctx {
		app.ctx.publisher
	}
	
	if path.ends_with('errors') || path.ends_with('error') || path.ends_with('errors.md')
		|| path.ends_with('error.md') {
		app.set_content_type('text/html')
		return return_html_errors(sitename, mut app)
	}

	if publisherobj.develop {
		filetype, sitename2, name2 := filetype_site_name_get(config, sitename, name) ?
		if debug {
			println(' >> get develop: $filetype, $sitename2, $name2')
		}

		if filetype == FileType.javascript || filetype == FileType.css {
			if debug {
				println(' >>> file static get: $filetype, $sitename2, $name2')
			}

			mut p := os.join_path(config.publish.paths.base, 'static', name2)
			mut content := os.read_file(p) or {
				if debug {
					println(' >>> file static not found or error: $p\n$err')
				}
				return app.not_found()
			}
			app.set_content_type(content_type_get(p) ?)
			if debug {
				content_type := content_type_get(p) ?
				len1 := content.len
				println(' >>> file static content type: $content_type, len:$len1')
			}
			return app.ok(content)
		}

		mut site2 := publisherobj.site_get(sitename2) or { return app.not_found() }
		if name2 == 'index.html' {
			// mut index := os.read_file( site.path + '/index.html') or {
			// 	res.send("index.html not found", 404)
			// }
			site_config := config.site_wiki_get(sitename2) ?
			index_out := template_wiki_root(sitename, '', '', site_config.opengraph)?
			return app.html(index_out)
		} else if filetype == FileType.wiki {
			if site2.page_exists(name2) {
				mut page := site2.page_get(name2, mut publisherobj) ?
				page.replace_defs(mut publisherobj) or { return app.server_error(2) }
				content := domain_replacer(rlock app.ctx {
					app.ctx.webnames
				}, page.content)
				return app.ok(content)
			} else {
				mut page_def := publisherobj.def_page_get(name2) ?
				page_def.replace_defs(mut publisherobj) or { return app.server_error(3) }
				// if debug {println(" >> page send: $name2")}
				content2 := domain_replacer(rlock app.ctx {
					app.ctx.webnames
				}, page_def.content)
				return app.ok(content2)
			}
		} else {
			// now is a file
			file3 := site2.file_get(name2, mut publisherobj) ?
			path3 := file3.path_get(mut publisherobj)?
			if debug {
				println(' >> file get: $path3')
			}
			content3 := os.read_file(path3) or { return app.not_found() }
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			app.set_content_type(content_type_get(path3) ?)
			return app.ok(content3)
		}
	} else {
		filetype, path2 := path_wiki_get(config, sitename, name) or {
			println(' - ERROR: could not get path for: $sitename:$name\n$err')
			return app.not_found()
		}
		if debug {
			println(" - '$sitename:$name' -> $path2")
		}
		if filetype == FileType.wiki {
			content := os.read_file(path2) or { return app.not_found() }
			return app.html(content)
		} else {
			if !os.exists(path2) {
				if debug {
					println(' - ERROR: cannot find path:$path2')
				}
				return app.not_found()
			} else {
				// println("deliver: '$path2'")
				content := os.read_file(path2) or { return app.not_found() }
				// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
				app.set_content_type(content_type_get(path2) ?)
				return app.ok(content)
			}
		}
	}
}

fn return_html_errors(sitename string, mut app App) vweb.Result {
	t := error_template(mut app, sitename)
	if t.starts_with('ERROR:') {
		return app.server_error(4)
	}
	// println(t)
	return app.ok(t)
}

fn error_template(mut app App, sitename string) string {
	config := rlock app.ctx {
		app.ctx.config
	}
	mut publisherobj := rlock app.ctx {
		app.ctx.publisher
	}
	mut errors := PublisherErrors{}
	mut site := publisherobj.site_get(sitename) or {
		return 'cannot get site, in template for errors\n $err'
	}
	if publisherobj.develop {
		errors = publisherobj.errors_get(site) or {
			return 'ERROR: cannot get errors, in template for errors\n $err'
		}
	} else {
		path2 := os.join_path(config.publish.paths.publish, 'wiki_$sitename', 'errors.json')
		err_file := os.read_file(path2) or { return 'ERROR: could not find errors file on $path2' }
		errors = json.decode(PublisherErrors, err_file) or {
			return 'ERROR: json not well formatted on $path2'
		}
	}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors.clone()
	return $tmpl('errors.html')
}

fn content_type_get(path string) ?string {
	if path.ends_with('.css') {
		return 'text/css'
	}
	if path.ends_with('.js') {
		return 'text/javascript'
	}
	if path.ends_with('.svg') {
		return 'image/svg+xml'
	}
	if path.ends_with('.png') {
		return 'image/png'
	}
	if path.ends_with('.jpeg') || path.ends_with('.jpg') {
		return 'image/jpg'
	}
	if path.ends_with('.gif') {
		return 'image/gif'
	}
	if path.ends_with('.pdf') {
		return 'application/pdf'
	}

	if path.ends_with('.zip') {
		return 'application/zip'
	}

	if path.ends_with('.html') {
		return 'text/html'
	}

	return error('cannot find content type for $path')
}

struct App {
	vweb.Context
pub mut:
	ctx shared MyContext
}

['/:path...']
pub fn (mut app App) handler(_path string) vweb.Result {
	config, publisherobj := rlock app.ctx {
		app.ctx.config, app.ctx.publisher
	}
	mut path := _path

	// enable CORS by default
	app.add_header("Access-Control-Allow-Origin", "*")

	// println(" ++ $path")

	mut domain := ''
	mut cat := publisher_config.SiteCat.web

	if config.web_hostnames {
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
			cat = publisher_config.SiteCat.wiki
		} else {
			cat = publisher_config.SiteCat.web
		}

		splitted := path.split('/')

		sitename := splitted[0]
		path = splitted[1..].join('/').trim('/').trim(' ')
		if splitted.len == 1 && (sitename.ends_with('.css') || sitename.ends_with('.js')) {
			p := os.join_path(config.publish.paths.base, 'static', sitename)
			content := os.read_file(p) or { return app.not_found() }
			app.set_content_type(content_type_get(p) or { return app.not_found() })
			return app.ok(content)
		}

		if sitename == '' {
			domain = 'localhost'
		} else {
			domain = config.domain_get(sitename, cat) or { return app.not_found() }
			println('DOMAIN:$domain')
		}
	}

	if domain == 'localhost' {
		return app.html(index_template(config))
	}

	mut iswiki := true
	mut domainfound := false
	for siteconfig in config.sites {
		if domain in siteconfig.domains {
			domainfound = true
			if siteconfig.cat == publisher_config.SiteCat.web {
				iswiki = false
			}
			break
		}
	}

	if !domainfound {
		return app.not_found()
	}

	if !iswiki {
		if publisherobj.develop {
			return app.not_found()
		}
		return site_www_deliver(config, domain, path, mut app) or { app.server_error(1) }
	} else {
		return site_wiki_deliver(config, domain, path, mut app) or { app.not_found() }
	}
}

pub fn (mut app App) index() vweb.Result {
	return app.handler('/')
}

// Run server
pub fn webserver_run(mut publisher &Publisher) ? {
	publisher.check() ?
	publisher.config.update_staticfiles(false) ?

	mut app := App{
		ctx: MyContext{
			publisher: publisher
			config: &publisher.config
		}
	}
	lock app.ctx {
		app.ctx.domain_replacer_init()
	}

	vweb.run(app, publisher.config.publish.port)
}
