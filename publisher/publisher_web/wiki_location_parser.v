
module publisher_web

import os
import freeflowuniverse.crystallib.texttools
import path

enum FileType {
	unknown
	wiki
	file
	image
	html
	javascript
	css
}

struct WikiLoc{
mut:
	filetype FileType
	sitename string
	pagename string
}

//return 
// struct WikiLoc{
// 	filetype FileType
// 	sitename string
// 	pagename string
// }
//
//if name has __ then is site__pagename, this needs to be split
// path is $relpath/$name or $name  (is after $wiki = which is the sitename)
fn wiki_location_parser (siteroot path.Path, relpath string) ?WikiLoc {

	//not good needs to be done better
	// if path.contains('/') && path.contains('sidebar') {
	// 	path = path.replace('/', '|')
	// 	path = path.replace('||', '|')
	// 	path = path.replace('_sidebar', 'sidebar')
	// }

	mut wl := WikiLoc{
		sitename : os.base(siteroot.path).to_lower().trim(' ').trim('.').trim(' ')
		pagename : os.base(relpath).to_lower().trim(' ').trim('.').trim(' ')
	}

	if wl.pagename.contains('__') {
		parts := wl.pagename.split('__')
		if parts.len != 2 {
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${wl.pagename}.')
		}
		wl.pagename = parts[0].trim(' ')
		wl.sitename = parts[1].trim(' ')
	}	
		
	extension := os.file_ext(wl.pagename).trim('.')

	// println( " - ${app.req.url}")
	if wl.pagename.trim(' ') == '' {
		wl.pagename = 'index.html'
	} else {
		wl.pagename = texttools.name_fix_keepext(wl.pagename)
	}


	if wl.pagename.ends_with('.html') {
		wl.filetype = FileType.html
	} else if wl.pagename.ends_with('.md') {
		wl.filetype = FileType.wiki
	} else if wl.pagename.ends_with('.js') {
		wl.filetype = FileType.javascript
	} else if wl.pagename.ends_with('css') {
		wl.filetype = FileType.css
	} else if extension == '' {
		wl.filetype = FileType.wiki
	} else {
		wl.filetype = FileType.file
	}

	if wl.filetype == FileType.wiki {
		if !wl.pagename.ends_with('.md') {
			wl.pagename += '.md'
		}
	}

	if wl.pagename == '_sidebar.md' {
		wl.pagename = 'sidebar.md'
	}

	if wl.pagename == '_navbar.md' {
		wl.pagename = 'navbar.md'
	}

	if wl.pagename == '_glossary.md' {
		wl.pagename = 'glossary.md'
	}

	return wl
}

fn wiki_name_from_url(url string) string {
	url_splitted := url.split('/')
	mut wiki_name := ''
	for id, element in url_splitted {
		if element == 'info' {
			wiki_name = url_splitted[id + 1].split('?')[0]
		}
	}
	return wiki_name
}

