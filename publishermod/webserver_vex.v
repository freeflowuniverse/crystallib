module publishermod

import os
import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx
import nedpals.vex.utils
import despiegk.crystallib.myconfig
import json

// this webserver is used for looking at the builded results

struct MyContext {
pub:
	config    &myconfig.ConfigRoot
	publisher &Publisher
pub mut:
	webnames map[string]string
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

fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println(utils.red_log('req.method $req.path'))
}

fn helloworld(req &ctx.Req, mut res ctx.Resp) {
	mut myconfig := (&MyContext(req.ctx)).config
	res.send('Hello World! $myconfig.paths.base', 200)
}

fn path_wiki_get(mut config myconfig.ConfigRoot, sitename_ string, name_ string) ?(FileType, string) {
	filetype, sitename, mut name := filetype_site_name_get(mut config, sitename_, name_) ?

	mut path2 := os.join_path(config.paths.publish, sitename, name)
	if name == 'readme.md' && (!os.exists(path2)) {
		name = 'sidebar.md'
		path2 = os.join_path(config.paths.publish, sitename, name)
	}
	// println('  > get: $path2 ($name)')

	if !os.exists(path2) {
		return error('cannot find file in: $path2')
	}
	return filetype, path2
}

fn filetype_site_name_get(mut config myconfig.ConfigRoot, site string, name_ string) ?(FileType, string, string) {
	// println(" - wiki get: '$site' '$name'")
	site_config := config.site_wiki_get(site) ?
	mut name := name_.to_lower().trim(' ').trim('.').trim(' ')
	extension := os.file_ext(name).trim('.')
	mut sitename := site_config.shortname
	if sitename.starts_with('wiki_') || sitename.starts_with('info_') {
		panic('sitename short cannot start with wiki_ or info_.\n$site_config')
	}

	if name.contains('__') {
		parts := name.split('__')
		if parts.len != 2 {
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${name}.')
		}
		sitename = parts[0].trim(' ')
		name = parts[1].trim(' ')
	}

	// println( " - ${app.req.url}")
	if name.trim(' ') == '' {
		name = 'index.html'
	} else {
		name = name_fix_keepext(name)
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

fn error_template(req &ctx.Req, sitename string) string {
	config := (&MyContext(req.ctx)).config
	mut publisherobj := (&MyContext(req.ctx)).publisher
	mut errors := PublisherErrors{}
	mut site := publisherobj.site_get(sitename) or {
		return 'cannot get site, in template for errors\n $err'
	}
	if publisherobj.develop {
		errors = publisherobj.errors_get(site) or {
			return 'ERROR: cannot get errors, in template for errors\n $err'
		}
	} else {
		path2 := os.join_path(config.paths.publish, 'wiki_$sitename', 'errors.json')
		err_file := os.read_file(path2) or { return 'ERROR: could not find errors file on $path2' }
		errors = json.decode(PublisherErrors, err_file) or {
			return 'ERROR: json not well formatted on $path2'
		}
	}
	mut site_errors := errors.site_errors
	mut page_errors := errors.page_errors.clone()
	return $tmpl('errors.html')
}

fn index_template(req &ctx.Req) string {
	mut config := (&MyContext(req.ctx)).config
	mut publisherobj := (&MyContext(req.ctx)).publisher
	mut sites := config.sites_get()
	mut port_str := ''
	if config.port != 80 {
		port_str = ':$config.port'
	}
	return $tmpl('index_root.html')
}

// Index (List of wikis) -- reads index.html
fn index_root(req &ctx.Req, mut res ctx.Resp) {
	res.headers['Content-Type'] = ['text/html']
	res.send(index_template(req), 200)
}

fn return_wiki_errors(sitename string, req &ctx.Req, mut res ctx.Resp) {
	t := error_template(req, sitename)
	if t.starts_with('ERROR:') {
		res.send(t, 501)
		return
	}
	// println(t)
	res.send(t, 200)
}

fn site_wiki_deliver(mut config myconfig.ConfigRoot, domain string, path string, req &ctx.Req, mut res ctx.Resp) ? {
	debug := true
	mut sitename := config.name_web_get(domain) or {
		res.send('Cannot find domain: $domain\n$err', 404)
		return
	}
	name := os.base(path)
	mut publisherobj := (&MyContext(req.ctx)).publisher
	if path.ends_with('errors') || path.ends_with('error') || path.ends_with('errors.md')
		|| path.ends_with('error.md') {
		return_wiki_errors(sitename, req, mut res)
		return
	}

	if publisherobj.develop {
		filetype, sitename2, name2 := filetype_site_name_get(mut config, sitename, name) ?
		// if debug {println(" >> page get develop: $name2")}

		if filetype == FileType.javascript || filetype == FileType.css {
			mut p := os.join_path(config.paths.base, 'static', name2)
			mut content := os.read_file(p) or {
				res.send('Cannot find file: $p\n$err', 404)
				return
			}
			res.headers['Content-Type'] = [content_type_get(p) ?]
			res.send(content, 200)
			return
		}

		mut site2 := publisherobj.site_get(sitename2) or {
			res.send('Cannot find site: $sitename2\n$err', 404)
			return
		}
		if name2 == 'index.html' {
			// mut index := os.read_file( site.path + '/index.html') or {
			// 	res.send("index.html not found", 404)
			// }
			site_config := config.site_wiki_get(sitename2) ?
			index_out := template_wiki_root(sitename, '', '', site_config.opengraph)
			res.headers['Content-Type'] = ['text/html']
			// index_root(req, mut res)
			res.send(index_out, 200)
			return
		} else if filetype == FileType.wiki {
			if site2.page_exists(name2) {
				mut page := site2.page_get(name2, mut publisherobj) ?
				// content4 := page.content_defs_replaced(mut publisherobj) ?
				// if debug {println(" >> page send: $name2")}
				// println(page.content)

				page.replace_defs(mut publisherobj) or {
					res.send('Cannot replace defs\n$err', 504)
					return
				}
				content := domain_replacer(req, page.content)
				res.send(content, 200)
				return
			} else {
				mut page_def := publisherobj.def_page_get(name2) ?
				page_def.replace_defs(mut publisherobj) or {
					res.send('Cannot replace defs\n$err', 504)
					return
				}
				// if debug {println(" >> page send: $name2")}
				content2 := domain_replacer(req, page_def.content)
				res.send(content2, 200)
				return
			}
		} else {
			// now is a file
			file3 := site2.file_get(name2, mut publisherobj) ?
			path3 := file3.path_get(mut publisherobj)
			// println (" >> file get: $path3")
			content3 := os.read_file(path3) or {
				res.send('Cannot find file: $path3\n$err', 404)
				return
			}
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			res.headers['Content-Type'] = [content_type_get(path3) ?]
			res.send(content3, 200)
		}
	} else {
		filetype, path2 := path_wiki_get(mut config, sitename, name) or {
			println(' - ERROR: could not get path for: $sitename:$name\n$err')
			res.send('$err', 404)
			return
		}
		if debug {
			println(" - '$sitename:$name' -> $path2")
		}
		if filetype == FileType.wiki {
			content := os.read_file(path2) or {
				res.send('Cannot find file: $path2\n$err', 404)
				return
			}
			res.headers['Content-Type'] = ['text/html']
			res.send(content, 200)
		} else {
			if !os.exists(path2) {
				if debug {
					println(' - ERROR: cannot find path:$path2')
				}
				res.send('cannot find path:$path2', 404)
				return
			} else {
				// println("deliver: '$path2'")
				content := os.read_file(path2) or {
					res.send('Cannot find file: $path2\n$err', 404)
					return
				}
				// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
				res.headers['Content-Type'] = [content_type_get(path2) ?]
				res.send(content, 200)
				// res.send_file(path2,200)
			}
		}
	}
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

	if path.ends_with('html') {
		return 'text/html'
	}

	return error('cannot find content type for $path')
}

fn site_www_deliver(mut config myconfig.ConfigRoot, domain string, path string, req &ctx.Req, mut res ctx.Resp) ? {
	mut site_path := config.path_publish_web_get_domain(domain) or {
		res.send('Cannot find domain: $domain\n$err', 404)
		return
	}
	mut path2 := path

	if path2.trim('/') == '' {
		path2 = 'index.html'
		res.headers['Content-Type'] = ['text/html']
	}
	path2 = os.join_path(site_path, path2)

	if !os.exists(path2) {
		println(' - ERROR: cannot find path:$path2')
		res.send('cannot find path:$path2', 404)
		return
	} else {
		if os.is_dir(path2) {
			path2 = os.join_path(path2, 'index.html')
			res.headers['Content-Type'] = ['text/html']
		}

		if path.ends_with('.html') {
			mut content := os.read_file(path2) or {
				res.send('Cannot find file: $path2\n$err', 404)
				return
			}
			content = domain_replacer(req, content)
			res.headers['Content-Type'] = ['text/html']
			res.send(content, 200)
		} else {
			// println("deliver: '$path2'")
			// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
			content2 := os.read_file(path2) or {
				res.send('Cannot find file: $path2\n$err', 404)
				return
			}
			res.headers['Content-Type'] = [content_type_get(path2) ?]
			res.send(content2, 200)
		}
	}
}

fn site_deliver(req &ctx.Req, mut res ctx.Resp) {
	mut config := (&MyContext(req.ctx)).config
	mut publisherobj := (&MyContext(req.ctx)).publisher

	// what is this doing?
	mut path := req.params['path']
	mut domain := ''

	mut cat := myconfig.SiteCat.web

	if config.web_hostnames {
		if !('Host' in req.headers) {
			panic('Host Header is required')
		}

		if req.headers['Host'].len == 0 {
			panic('Host is missing')
		}

		mut host := req.headers['Host'][0]
		mut splitted2 := host.split(':')
		domain = splitted2[0]
	} else {
		path = path.trim('/')
		if path.starts_with('info/') {
			path = path[5..]
			cat = myconfig.SiteCat.wiki
		} else {
			cat = myconfig.SiteCat.web
		}

		splitted := path.split('/')

		sitename := splitted[0]
		path = splitted[1..].join('/').trim('/').trim(' ')

		if sitename.ends_with('.css') || sitename.ends_with('js') {
			mut p := os.join_path(config.paths.base, 'static', sitename)
			mut content := os.read_file(p) or {
				res.send('Cannot find file: $p\n$err', 404)
				return
			}
			res.headers['Content-Type'] = [content_type_get(p) or { panic(err) }]
			res.send(content, 200)
			return
		}

		if sitename == '' {
			domain = 'localhost'
		} else {
			domain = config.domain_get(sitename, cat) or {
				res.send('unknown domain for ${sitename}.\n$err', 404)
				return
			}
			println('DOMAIN:$domain')
		}
	}

	if domain == 'localhost' {
		index_root(req, mut res)
		return
	}

	mut iswiki := true

	mut domainfound := false
	for siteconfig in config.sites {
		if domain in siteconfig.domains {
			domainfound = true
			if siteconfig.cat == myconfig.SiteCat.web {
				iswiki = false
			}
			break
		}
	}

	if !domainfound {
		res.send('unknown domain $domain', 404)
		return
	}

	if !iswiki {
		if publisherobj.develop {
			res.send('websites cannot be shown in development mode', 404)
			return
		}
		site_www_deliver(mut config, domain, path, req, mut res) or {
			res.send('unknown error.\n$err', 501)
			return
		}
	} else if iswiki {
		site_wiki_deliver(mut config, domain, path, req, mut res) or {
			res.send('unknown error.\n$err', 404)
			return
		}
	}
}

// Run server
pub fn webserver_run(publisher &Publisher, config &myconfig.ConfigRoot) {
	mut app := router.new()

	mut mycontext := &MyContext{
		config: config
		publisher: publisher
	}

	mycontext.domain_replacer_init()

	app.inject(mycontext)

	app.use(print_req_info)
	app.route(.get, '/*path', site_deliver)

	server.serve(app, config.port)
}
