module publishermod

// import os
// import vweb
// import myconfig
// import json

// //this webserver is used for looking at the builded results

// const (
// 	port = 9998
// )

// enum FileType{
// 	wiki
// 	file
// 	image
// 	html
// }
// struct App{
//  	vweb.Context
// pub mut:
//  	cnt      int
// 	config 	myconfig.ConfigRoot
// 	website string
// }

// struct PublisherErrors{
// 		pub:
// 			site_errors []SiteError
// 			page_errors map [string][]PageError
// 	}

// // Run server
// pub fn webserver_run() {	
// 	vweb.run<App>(port){}
// }

// // Initialize (load wikis) only once when server starts
// pub fn (mut app App) init_once() {
// 	app.config = myconfig.get()
// 	// app.handle_static('.')
// }

// // Initialization code goes here (with each request)
// pub fn (mut app App) init() {

// }

// // Index (List of wikis) -- reads index.html
// pub fn (mut app App) index() vweb.Result {
// 	mut wikis := []string{}
// 	path := os.join_path(app.config.paths.publish)
// 	list := os.ls(path) or {panic(err)}

// 	app.enable_chunked_transfer(40)

// 	for item in list{
// 			wikis << item
// 	}	

// 	return $vweb.html()
// }

// fn (mut app App) site_config_get(name string)? myconfig.SiteConfig{

// 	name2 := name_fix_keepext(name)

// 	for site in app.config.sites{
// 		if site.name.to_lower() == "info_"+name2.to_lower(){
// 			return site
// 		}
// 		if site.name.to_lower() == name2.to_lower(){
// 			return site
// 		}		
// 	}
// 	return error("Cannot find wiki site with name: $name2")
// }

// fn (mut app App) static_check()bool {
// 	if app.website != "" {
// 		return true
// 	}
// 	return false	
// }

// [get]
// fn (mut app App) static_return() vweb.Result {
// 	// site_config := app.site_config_get(app.website) or {panic(err)}
// 	path := "${app.config.paths.publish}/${app.website}/${app.req.url}"
// 	println(" - static: '$path'")
// 	mut f := os.read_file( path) or {return app.not_found()}
// 	return app.ok(f)	
// }

// fn (mut app App) path_get(site string, name string)? (FileType, string) {

// 	site_config := app.site_config_get(site) ?
// 	mut name2 := name.to_lower().trim(" ")
// 	mut path2 := ""
// 	extension := os.file_ext(name2).trim(".")
// 	mut sitename := site_config.name
// 	if sitename.starts_with("wiki_") || sitename.starts_with("info_"){
// 		sitename = sitename[5..]
// 	}

// 	if name.starts_with("file__") || name.starts_with("page__") || name.starts_with("html__"){
// 		splitted := name.split("__")
// 		if splitted.len != 3{
// 			return error("filename not well formatted. Needs to have 3 parts. Now $name2 .")
// 		}
// 		name2 = splitted[2]
// 		if sitename != splitted[1]{
// 			return error("Sitename in name should correspond to ${sitename}. Now $name2 .")
// 		}
// 	}

// 	mut filetype := FileType{}
// 	if name2.starts_with("file__"){
// 		// app.set_content_type('text/html')
// 		app.set_content_type('image/' + extension)
// 		filetype = FileType.file
// 	}else if name2.starts_with("page__"){
// 		app.set_content_type('text/html')
// 		filetype = FileType.wiki
// 	}else if name2.starts_with("html__"){
// 		app.set_content_type('text/html')
// 		filetype = FileType.html
// 	} else if name2.ends_with(".md"){
// 		app.set_content_type('text/html')
// 		filetype = FileType.wiki		
// 	} else if name2.ends_with(".html"){
// 		app.set_content_type('text/html')
// 		filetype = FileType.html		
// 	}else {
// 		//consider all to be files (images)
// 		app.set_content_type('image/' + extension)
// 		filetype = FileType.file
// 	}

// 	//use known extensions for mime_types
// 	if ".$extension" in vweb.mime_types{
// 		app.set_content_type(vweb.mime_types[".$extension"])
// 	}

// 	println( " - ${app.req.url}")

// 	name2 = name_fix_keepext(name2)

// 	if name2 == '_sidebar.md'{
// 		name2 = 'sidebar.md'
// 	}

// 	if name2 == '_navbar.md'{
// 		name2 = 'navbar.md'
// 	}

// 	path2 = os.join_path(app.config.paths.publish, sitename, name2)

// 	if name2 == 'readme.md' && (!os.exists(path2)){
// 		name2 = "sidebar.md"
// 		path2 = os.join_path(app.config.paths.publish, sitename, name2)
// 	}

// 	println("  > get: $path2 ($name)")

// 	if ! os.exists(path2){
// 		return error("cannot find file in: $path2")
// 	}	

// 	return filetype, path2

// }

// [get]
// ['/:sitename']
// pub fn (mut app App) get_wiki(sitename string) vweb.Result {
// 	siteconfig := app.site_config_get(sitename) or {
// 		app.set_status(501,"$err")
// 		return app.not_found()
// 	}

// 	if app.static_check(){
// 		return app.static_return()
// 	}
// 	site_config := app.site_config_get(sitename) or {
// 		app.set_status(501,"$err")
// 		println(" >> **ERROR: $err")
// 		return app.ok("$err")
// 	}

// 	//now check if is static website
// 	if site_config.cat == myconfig.SiteCat.web{
// 		app.website = site_config.name
// 	}

// 	path := os.join_path(app.config.paths.publish, sitename, "index.html")
// 	if ! os.exists(path){
// 		// panic ("need to have index.html file in the wiki repo")
// 		reponame := siteconfig.name
// 		repourl := siteconfig.url
// 		theme_simple := "https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-simple.css"
// 		docsify_tabs := "https://cdn.jsdelivr.net/npm/docsify-tabs@1"
// 		docsify_themable := "https://cdn.jsdelivr.net/npm/docsify-themeable@0"
// 		return $vweb.html()
// 	}
// 	file := os.read_file(path) or {return app.not_found()}
// 	app.set_content_type('text/html')
// 	return app.ok(file)
// }

// [get]
// ['/:sitename/:filename']
// pub fn (mut app App) get_wiki_file(sitename string, filename string) vweb.Result {

// 	if app.static_check(){
// 		return app.static_return()
// 	}

// 	_, path := app.path_get(sitename, filename) or {
// 		app.set_status(501,"$err")
// 		println(" >> **ERROR: $err")
// 		return app.not_found()
// 	}
// 	mut f := os.read_file( path) or {return app.not_found()}
// 	return app.ok(f)
// }

// [get]
// ['/:sitename/img/:filename']
// pub fn (mut app App) get_wiki_img(sitename string, filename string) vweb.Result {
// 	if app.static_check(){
// 		return app.static_return()
// 	}
// 	return app.get_wiki_file(sitename, filename)
// }

// [get]
// ['/:sitename/errors']
// pub fn (mut app App) errors(sitename string) vweb.Result {
// 	siteconfig := app.site_config_get(sitename) or {
// 		app.set_status(501,"$err")
// 		return app.not_found()
// 	}

// 	path := os.join_path(app.config.paths.publish, sitename, "errors.json")
// 	err_file := os.read_file(path) or {
// 			println(" >> **ERROR: could not find errors file on $path")
// 			app.set_status(501,"could not find errors file on $path")
// 			return app.not_found()
// 		}

// 	errors := json.decode(PublisherErrors, err_file) or {
// 			println(" >> **ERROR: json not well formatted on $path")
// 			app.set_status(501,"json not well formatted on $path")
// 			return app.not_found()
// 		}

// 	mut site_errors := errors.site_errors
// 	mut page_errors := errors.page_errors

// 	return $vweb.html()
// }
