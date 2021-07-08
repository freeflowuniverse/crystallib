module publisher_core

// this webserver is used for doing development on wiki

// IMPORTANT NEED TO MODIFY WEBSERVER.V TO ALSO SUPPORT GETTING INFO FROM THE PUBLISHING TOOLS DIRECTLY

// import os
// import vweb
// import myconfig
// // import json

// const (
// 	port2 = 9999
// )

// struct App2 {
//  vweb.Context
// pub mut:
//  cnt      int
//  publisher Publisher
// //  configdata myconfig.ConfigRoot
// }

// // Run server
// pub fn webserver_start_develop() {	
// 	vweb.run<App2>(port2){}
// }

// // Initialize (load wikis) only once when server starts
// pub fn (mut app App2) init_once() {
// 	app.config := myconfig.get()
// 	app.publisher = publisher_core.new(configdata.paths.code) or { panic('cannot init publisher. $err') }
// 	app.publisher.check()

// }

// // Initialization code goes here (with each request)
// pub fn (mut app App2) init() {}

// // Index (List of wikis) -- reads index.html
// pub fn (mut app App2) index() vweb.Result {
// 	mut wikis := []string{}
// 	for site in app.publisher.sites {
// 		wikis << site.name
// 	}
// 	//get the index from the published website location
// 	return $vweb.html()
// }

// [get]
// ['/:sitename']
// pub fn (mut app App2) get_wiki(sitename string) vweb.Result {
// 	mut site := app.publisher.site_get(sitename) or { return app.not_found() }
// 	path := site.path
// 	mut index := os.read_file( path + '/index.html') or {
// 		return app.not_found()
// 	}
// 	app.set_content_type('text/html')
// 	return app.ok(index)
// }

// [get]
// ['/:sitename/:filename']
// pub fn (mut app App2) get_wiki_file(sitename string, filename string) vweb.Result {
// 	if filename.starts_with("file__"){
// 		splitted := filename.split("__")
// 		if splitted.len != 3{
// 			return app.not_found()
// 		}
// 		return app.get_wiki_img(splitted[1], splitted[2])
// 	}

// 	if filename.starts_with("page__"){
// 		splitted := filename.split("__")
// 		if splitted.len != 3{
// 			return app.not_found()
// 		}
// 		return app.get_wiki_file(splitted[1], splitted[2])
// 	}

// 	if filename.starts_with("html__"){
// 		mut splitted := filename.split("__")

// 		if splitted.len < 3{
// 			return app.not_found()
// 		}

// 		mut site := app.publisher.site_get(splitted[1]) or { return app.not_found() }
// 		mut path := os.join_path(site.path, splitted[2..].join("/"))

// 		mut f := os.read_file( path) or {return app.not_found()}
// 		app.set_content_type('text/html')
// 		return app.ok(f)	
// 	}

// 	mut site := app.publisher.site_get(sitename) or { return app.not_found() }

// 	root := site.path
// 	if filename.starts_with('_') {//why do we do this?
// 		mut file := os.read_file(os.join_path(root, filename)) or { return app.not_found() }
// 		app.set_content_type('text/html')
// 		return app.ok(file)
// 	} else {
// 		mut file := ''
// 		if filename.ends_with('.md') {
// 			app.set_content_type('text/html')
// 			mut pageobj := site.page_get("$filename", mut &app.publisher) or {
// 				if filename == 'README.md' {
// 					file = os.read_file(os.join_path(root, '_sidebar.md')) or {
// 						return app.not_found()
// 					}
// 					app.set_content_type('text/html')
// 					return app.ok('# $sitename\n' + file)
// 				}
// 				return app.not_found()
// 			}
// 			pageobj.process(mut &app.publisher) or {panic(err)}
// 			file = pageobj.content
// 		} else {
// 			img := site.file_get(filename, mut app.publisher) or { return app.not_found() }
// 			//shouldn't we return as static, this brings everything in memory?
// 			file = os.read_file(img.path_get(mut &app.publisher)) or { return app.not_found() }
// 			extension := filename.split('.')[1]
// 			app.set_content_type('image/' + extension)
// 		}
// 		return app.ok(file)
// 	}
// }

// [get]
// ['/:sitename/img/:filename']
// pub fn (mut app App2) get_wiki_img(sitename string, filename string) vweb.Result {
// 	mut site := app.publisher.site_get(sitename) or { return app.not_found() }
// 	site.files_process(mut &app.publisher) or {panic(err)}
// 	img := site.file_get(filename, mut &app.publisher) or { return app.not_found() }
// 	file := os.read_file(img.path_get(mut &app.publisher)) or { return app.not_found() }
// 	extension := filename.split('.')[1]
// 	app.set_content_type('image/' + extension)
// 	return app.ok(file)
// }

// [get]
// ['/:sitename/errors']
// pub fn (mut app App2) errors(sitename string) vweb.Result {
// 	mut site := app.publisher.site_get(sitename) or { return app.not_found() }
// 	site.load(mut &app.publisher)
// 	mut site_errors := []SiteError{}

// 	for err in site.errors{
// 		if err.cat !=SiteErrorCategory.duplicatefile &&
// 				err.cat !=SiteErrorCategory.duplicatepage{
// 			site_errors << err
// 		}
// 	}

// 	mut page_errors := map[string][]PageError{}

// 	for name, _ in site.pages{
// 		page := site.page_get(name, mut &app.publisher) or { return app.not_found() }
// 		if page.errors.len > 0{
// 			page_errors[name] = page.errors
// 		}
// 	}
// 	return $vweb.html()
// }
