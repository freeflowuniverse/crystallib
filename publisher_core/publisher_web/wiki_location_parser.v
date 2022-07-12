
module publisher_web


// import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_core

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
// path is $wiki/$relpath/$name or $wiki/$name
fn wiki_location_parser (path string) ?WikiLoc {

	panic("not implemented yet")

	//not good needs to be done better
	if path.contains('/') && path.contains('sidebar') {
		path = path.replace('/', '|')
		path = path.replace('||', '|')
		path = path.replace('_sidebar', 'sidebar')
	}

	mut wl := WikiLoc{
		name := os.base(path).to_lower().trim(' ').trim('.').trim(' ')
	}

	if wl.pagename.contains('__') {
		parts := wl.pagename.split('__')
		if parts.len != 2 {
			return error('filename not well formatted. Needs to have 2 parts around "__". Now ${name}.')
		}
		wl.pagename = parts[0].trim(' ')
		wl.site = parts[1].trim(' ')
	}	
		
	extension := os.file_ext(name).trim('.')

	// println( " - ${app.req.url}")
	if wl.pagename.trim(' ') == '' {
		wl.pagename = 'index.html'
	} else {
		wl.pagename = texttools.name_fix_keepext(name)
	}

	mut filetype := FileType{}

	if wl.pagename.ends_with('.html') {
		filetype = FileType.html
	} else if wl.pagename.ends_with('.md') {
		filetype = FileType.wiki
	} else if wl.pagename.ends_with('.js') {
		name = name_
		filetype = FileType.javascript
	} else if wl.pagename.ends_with('css') {
		name = name_
		filetype = FileType.css
	} else if extension == '' {
		filetype = FileType.wiki
	} else {
		filetype = FileType.file
	}

	if filetype == FileType.wiki {
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

	wl.sitename = threefold_sitename_modifier(wl.sitename)

	return wl
}

