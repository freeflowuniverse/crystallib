
module publisher_web
import vweb
import os
import path as crystalpath

struct Site{
pub mut:
	name string
	cat SiteType
}


//get the html frontpage for a wiki website
fn  (mut app App) wiki_frontpage_get () string {

	mut sites := []Site{}

	return $tmpl('templates/index_root.html')
}


// sitepath is the full path to the wiki
fn (mut app App) handle_wiki(siteroot_ string, relpath string) ?vweb.Result {

	mut siteroot := crystalpath.get(siteroot_)

	$if debug {
		eprintln(' >>> Webserver >> path >> $relpath')
		// println(' >>> Webserver >> req >> $req')
		// println(' >>> Webserver >> res >> $res')		
	}

	//TODO: need to deal with side_bar

	mut wl := wiki_location_parser(siteroot,relpath)?
	mut pathfull := os.join_path(siteroot.path,relpath)

	// if wl.pagename == 'readme.md' && (!os.exists(pathfull)) {
		
	// 	pathfull.replace("readme.md") = 'sidebar.md'
	// 	pathfull = os.join_path(siteroot, wl.relpath)
	// }

	if !os.exists(pathfull) {
		return error('cannot find file in: $pathfull')
	}
	// filetype, path2 := path_wiki_get(config, sitename, name) or {
	// 	println(' - ERROR: could not get path for: $sitename:$name\n$err')
	// 	return app.not_found()
	// }
	$if debug {
		eprintln(" - '${wl.sitename}:${wl.name}' -> $pathfull")
	}
	if wl.filetype == FileType.wiki {
		content := os.read_file(pathfull) or { return app.not_found() }
		return app.html(content)
	} else {
		content := os.read_file(pathfull) or { return app.not_found() }
		// NOT GOOD NEEDS TO BE NOT LIKE THIS: TODO: find way how to send file
		app.set_content_type(content_type_get(pathfull)?)
		return app.ok(content)
	}

	return app.not_found()

}